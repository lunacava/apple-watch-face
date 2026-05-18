import SwiftUI

@main
struct VerticalSliderApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Vertical Slider")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
        }
    }
}
