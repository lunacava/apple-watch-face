import SwiftUI

@main
struct VerticalSliderWatchApp: App {
    @State private var healthKitManager = HealthKitManager()
    @State private var faceSettings = FaceSettings()
    @State private var workoutManager = WorkoutManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(healthKitManager)
                .environment(faceSettings)
                .environment(workoutManager)
        }
    }
}
