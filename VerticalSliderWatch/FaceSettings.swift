import SwiftUI
import Observation

@MainActor
@Observable
final class FaceSettings {
    var accentColorName: String {
        didSet { UserDefaults.standard.set(accentColorName, forKey: "accentColor") }
    }
    var backgroundColorName: String {
        didSet { UserDefaults.standard.set(backgroundColorName, forKey: "backgroundColor") }
    }
    var showSteps: Bool {
        didSet { UserDefaults.standard.set(showSteps, forKey: "showSteps") }
    }
    var showDate: Bool {
        didSet { UserDefaults.standard.set(showDate, forKey: "showDate") }
    }
    var layoutMode: String {
        didSet { UserDefaults.standard.set(layoutMode, forKey: "layoutMode") }
    }

    static let layoutOptions = ["timeline", "simple"]

    var accentColor: Color {
        switch accentColorName {
        case "blue": Color(red: 0.2, green: 0.5, blue: 1.0)
        case "green": Color(red: 0.0, green: 1.0, blue: 0.4)
        case "red": Color(red: 1.0, green: 0.1, blue: 0.15)
        case "yellow": Color(red: 1.0, green: 0.78, blue: 0.0)
        case "purple": Color(red: 0.9, green: 0.2, blue: 0.7)
        case "white": Color.white
        default: Color(red: 0.2, green: 0.65, blue: 1.0)
        }
    }

    var backgroundColor: Color {
        switch backgroundColorName {
        case "black": Color.black
        case "darkGray": Color(red: 0.15, green: 0.15, blue: 0.15)
        case "charcoal": Color(red: 0.2, green: 0.2, blue: 0.2)
        case "khaki": Color(red: 0.18, green: 0.2, blue: 0.12)
        case "tanDesert": Color(red: 0.26, green: 0.22, blue: 0.16)
        case "olive": Color(red: 0.15, green: 0.18, blue: 0.1)
        case "navy": Color(red: 0.08, green: 0.1, blue: 0.18)
        default: Color.black
        }
    }

    static let colorOptions = ["blue", "green", "red", "yellow", "purple", "white"]
    static let bgColorOptions = ["black", "darkGray", "khaki", "tanDesert", "olive", "navy"]

    static func bgColorLabel(_ name: String) -> String {
        switch name {
        case "black": "Black"
        case "darkGray": "Dark Gray"
        case "charcoal": "Charcoal"
        case "khaki": "Khaki"
        case "tanDesert": "Tan Desert"
        case "olive": "Olive"
        case "navy": "Navy"
        default: name
        }
    }

    static func bgColorValue(_ name: String) -> Color {
        switch name {
        case "black": Color.black
        case "darkGray": Color(red: 0.15, green: 0.15, blue: 0.15)
        case "charcoal": Color(red: 0.2, green: 0.2, blue: 0.2)
        case "khaki": Color(red: 0.18, green: 0.2, blue: 0.12)
        case "tanDesert": Color(red: 0.26, green: 0.22, blue: 0.16)
        case "olive": Color(red: 0.15, green: 0.18, blue: 0.1)
        case "navy": Color(red: 0.08, green: 0.1, blue: 0.18)
        default: Color.black
        }
    }

    init() {
        self.accentColorName = UserDefaults.standard.string(forKey: "accentColor") ?? "blue"
        self.backgroundColorName = UserDefaults.standard.string(forKey: "backgroundColor") ?? "black"
        self.showSteps = UserDefaults.standard.object(forKey: "showSteps") as? Bool ?? true
        self.showDate = UserDefaults.standard.object(forKey: "showDate") as? Bool ?? true
        self.layoutMode = UserDefaults.standard.string(forKey: "layoutMode") ?? "timeline"
    }
}
