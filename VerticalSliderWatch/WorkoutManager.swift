import Foundation
import HealthKit
import Observation

@MainActor
@Observable
final class WorkoutManager: NSObject {
    var isActive: Bool = false
    var errorMessage: String?
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    var keepAliveEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "keepAlive") }
        set { UserDefaults.standard.set(newValue, forKey: "keepAlive") }
    }

    func startIfNeeded() {
        if keepAliveEnabled && !isActive {
            startSession()
        }
    }

    func startSession() {
        guard session == nil else { return }
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "HealthKit unavailable"
            return
        }

        let config = HKWorkoutConfiguration()
        config.activityType = .other
        config.locationType = .indoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            builder = session?.associatedWorkoutBuilder()
            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)

            session?.delegate = self
            builder?.delegate = self

            let startDate = Date()
            session?.startActivity(with: startDate)
            builder?.beginCollection(withStart: startDate) { [weak self] success, error in
                Task { @MainActor in
                    if success {
                        self?.isActive = true
                        self?.keepAliveEnabled = true
                        self?.errorMessage = nil
                    } else {
                        self?.errorMessage = error?.localizedDescription
                        self?.isActive = false
                    }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            isActive = false
            session = nil
            builder = nil
        }
    }

    func stopSession() {
        session?.end()
        let currentBuilder = builder
        currentBuilder?.endCollection(withEnd: Date()) { _, _ in
            currentBuilder?.finishWorkout { _, _ in }
        }
        session = nil
        builder = nil
        isActive = false
        keepAliveEnabled = false
    }

    func recoverSession() {
        healthStore.recoverActiveWorkoutSession { [weak self] session, error in
            Task { @MainActor in
                guard let self = self else { return }
                if let session = session {
                    self.session = session
                    session.delegate = self
                    self.builder = session.associatedWorkoutBuilder()
                    self.builder?.delegate = self
                    self.isActive = (session.state == .running)
                } else if self.keepAliveEnabled {
                    self.startSession()
                }
            }
        }
    }
}

extension WorkoutManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        Task { @MainActor in
            self.isActive = (toState == .running)
            if toState == .ended || toState == .stopped {
                if self.keepAliveEnabled {
                    self.session = nil
                    self.builder = nil
                    self.startSession()
                }
            }
        }
    }

    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        Task { @MainActor in
            self.errorMessage = error.localizedDescription
            self.isActive = false
            if self.keepAliveEnabled {
                self.session = nil
                self.builder = nil
                self.startSession()
            }
        }
    }
}

extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {}
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}
