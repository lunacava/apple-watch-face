import Foundation
import HealthKit
import Observation

@MainActor
@Observable
final class HealthKitManager {
    var stepCount: Int = 0
    private let healthStore = HKHealthStore()
    private var queryTask: Task<Void, Never>?

    init() {
        requestAuthorization()
    }

    private func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let stepType = HKQuantityType(.stepCount)
        let typesToRead: Set<HKObjectType> = [stepType]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, _ in
            if success {
                Task { @MainActor in
                    self?.fetchTodaySteps()
                    self?.startPeriodicUpdates()
                }
            }
        }
    }

    func fetchTodaySteps() {
        let stepType = HKQuantityType(.stepCount)
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            guard let sum = result?.sumQuantity() else { return }
            let steps = Int(sum.doubleValue(for: .count()))
            Task { @MainActor in
                self?.stepCount = steps
            }
        }
        healthStore.execute(query)
    }

    private func startPeriodicUpdates() {
        queryTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(300))
                self?.fetchTodaySteps()
            }
        }
    }
}
