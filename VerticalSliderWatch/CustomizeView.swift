import SwiftUI

struct CustomizeView: View {
    @Environment(FaceSettings.self) private var settings
    @Environment(WorkoutManager.self) private var workoutManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Layout") {
                    ForEach(FaceSettings.layoutOptions, id: \.self) { mode in
                        Button {
                            settings.layoutMode = mode
                        } label: {
                            HStack {
                                Text(mode == "timeline" ? "Timeline" : "Simple")
                                    .font(.system(size: 14))
                                Spacer()
                                if settings.layoutMode == mode {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12))
                                        .foregroundColor(colorFor(settings.accentColorName))
                                }
                            }
                        }
                        .listRowBackground(Color.black)
                    }
                }

                Section("Background") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 36))], spacing: 8) {
                        ForEach(FaceSettings.bgColorOptions, id: \.self) { name in
                            Circle()
                                .fill(FaceSettings.bgColorValue(name))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle().stroke(
                                        settings.backgroundColorName == name
                                            ? colorFor(settings.accentColorName)
                                            : Color.white.opacity(0.3),
                                        lineWidth: settings.backgroundColorName == name ? 2 : 1
                                    )
                                )
                                .onTapGesture { settings.backgroundColorName = name }
                        }
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.black)
                }

                Section("Accent") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 36))], spacing: 8) {
                        ForEach(FaceSettings.colorOptions, id: \.self) { name in
                            Circle()
                                .fill(colorFor(name))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle().stroke(
                                        settings.accentColorName == name
                                            ? Color.white
                                            : Color.clear,
                                        lineWidth: 2
                                    )
                                )
                                .onTapGesture { settings.accentColorName = name }
                        }
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.black)
                }

                Section("Complications") {
                    Toggle("Steps", isOn: Bindable(settings).showSteps)
                        .font(.system(size: 14))
                        .listRowBackground(Color.black)
                    Toggle("Date", isOn: Bindable(settings).showDate)
                        .font(.system(size: 14))
                        .listRowBackground(Color.black)
                }

                Section("Always On") {
                    Button {
                        if workoutManager.isActive {
                            workoutManager.stopSession()
                        } else {
                            workoutManager.startSession()
                        }
                    } label: {
                        HStack {
                            Text("Keep Alive")
                                .font(.system(size: 14))
                            Spacer()
                            Text(workoutManager.isActive ? "ON" : "OFF")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(workoutManager.isActive ? .green : .gray)
                        }
                    }
                    .listRowBackground(Color.black)

                    if let error = workoutManager.errorMessage {
                        Text(error)
                            .font(.system(size: 10))
                            .foregroundColor(.red)
                            .listRowBackground(Color.black)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 14))
                }
            }
        }
    }

    private func colorFor(_ name: String) -> Color {
        switch name {
        case "blue": Color(red: 0.2, green: 0.5, blue: 1.0)
        case "green": Color(red: 0.0, green: 1.0, blue: 0.4)
        case "red": Color(red: 1.0, green: 0.1, blue: 0.15)
        case "yellow": Color(red: 1.0, green: 0.78, blue: 0.0)
        case "purple": Color(red: 0.9, green: 0.2, blue: 0.7)
        case "white": Color.white
        default: Color.white
        }
    }
}
