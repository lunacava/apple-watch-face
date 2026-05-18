import SwiftUI

struct ContentView: View {
    @Environment(HealthKitManager.self) private var healthKitManager
    @Environment(FaceSettings.self) private var settings
    @Environment(WorkoutManager.self) private var workoutManager
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    @State private var showCustomize = false

    private var useSimpleLayout: Bool {
        settings.layoutMode == "simple" || isLuminanceReduced
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: isLuminanceReduced ? 60.0 : 1.0)) { timeline in
            let date = timeline.date
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                ZStack {
                    settings.backgroundColor

                    if useSimpleLayout {
                        SimpleTimeView(
                            date: date,
                            viewWidth: w,
                            viewHeight: h,
                            accentColor: settings.accentColor
                        )
                    } else {
                        VerticalTimeRuler(
                            date: date,
                            viewWidth: w,
                            viewHeight: h,
                            accentColor: settings.accentColor,
                            dimmed: false
                        )
                    }

                    HStack(spacing: 0) {
                        if settings.showDate {
                            TimeInfoPanel(date: date, panelHeight: h, dimmed: useSimpleLayout)
                                .frame(width: w * 0.22)
                        } else {
                            Spacer().frame(width: w * 0.22)
                        }

                        Spacer()

                        if settings.showSteps {
                            StepCountView(
                                stepCount: healthKitManager.stepCount,
                                viewHeight: h,
                                accentColor: settings.accentColor,
                                dimmed: useSimpleLayout
                            )
                            .frame(width: w * 0.20)
                        } else {
                            Spacer().frame(width: w * 0.20)
                        }
                    }
                }
                .opacity(isLuminanceReduced ? 0.6 : 1.0)
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden)
        .persistentSystemOverlays(.hidden)
        .onLongPressGesture(minimumDuration: 0.5) {
            showCustomize = true
        }
        .sheet(isPresented: $showCustomize) {
            CustomizeView()
        }
        .onAppear {
            workoutManager.recoverSession()
        }
    }
}
