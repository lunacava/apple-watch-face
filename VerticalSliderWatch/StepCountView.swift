import SwiftUI

struct StepCountView: View {
    let stepCount: Int
    let viewHeight: CGFloat
    let accentColor: Color
    var dimmed: Bool = false

    private let stepInterval: Int = 500
    private let pixelsPer500: CGFloat = 60

    private func label(for value: Int) -> String {
        if value == 0 { return "0" }
        if value >= 1000 && value % 1000 == 0 {
            return "\(value / 1000)K"
        }
        return "\(value)"
    }

    var body: some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height
            let barX = width - 4
            let centerY = height / 2.0
            let pixelsPerStep = pixelsPer500 / CGFloat(stepInterval)

            let currentY = centerY
            let zeroY = currentY - CGFloat(stepCount) * pixelsPerStep


            let maxMarker = stepCount + stepInterval * 4
            var value = 0
            while value <= maxMarker {
                let y = zeroY + CGFloat(value) * pixelsPerStep

                if y > -40 && y < height + 40 {
                    if !dimmed {
                        var tickPath = Path()
                        tickPath.move(to: CGPoint(x: barX - 4, y: y))
                        tickPath.addLine(to: CGPoint(x: barX + 4, y: y))
                        context.stroke(tickPath, with: .color(.white.opacity(0.35)), lineWidth: 1.0)
                    }

                    let text = Text(label(for: value))
                        .font(.custom("OCRAExtended", size: 14))
                        .tracking(-1)
                        .foregroundColor(.white.opacity(dimmed ? 0.3 : 0.5))
                    context.draw(
                        context.resolve(text),
                        at: CGPoint(x: barX - 6, y: y),
                        anchor: .trailing
                    )
                }

                value += stepInterval
            }

        }
        .frame(height: viewHeight)
    }
}
