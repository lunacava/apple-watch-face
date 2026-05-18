import SwiftUI

struct SimpleTimeView: View {
    let date: Date
    let viewWidth: CGFloat
    let viewHeight: CGFloat
    let accentColor: Color

    private var calendar: Calendar { Calendar.current }
    private var hour: Int { calendar.component(.hour, from: date) }
    private var minute: Int { calendar.component(.minute, from: date) }

    var body: some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height
            let centerY = height / 2.0
            let textY = centerY - height * 0.08
            let rulerX = width * 0.66

            var rulerPath = Path()
            rulerPath.move(to: CGPoint(x: rulerX, y: 0))
            rulerPath.addLine(to: CGPoint(x: rulerX, y: height))
            context.stroke(rulerPath, with: .color(.white.opacity(0.15)), lineWidth: 1.0)

            let hourStr = String(format: "%02d", hour)
            let hourText = Text(hourStr)
                .font(.custom("OCRAExtended", size: 82))
                .tracking(-6)
                .foregroundColor(.white)
            context.draw(
                context.resolve(hourText),
                at: CGPoint(x: rulerX - 8, y: textY),
                anchor: .trailing
            )

            let minStr = String(format: "%02d", minute)
            let minText = Text(minStr)
                .font(.custom("OCRAExtended", size: 28))
                .tracking(-2)
                .foregroundColor(.white.opacity(0.7))
            context.draw(
                context.resolve(minText),
                at: CGPoint(x: rulerX + 8, y: textY),
                anchor: .leading
            )

            var linePath = Path()
            linePath.move(to: CGPoint(x: 0, y: centerY))
            linePath.addLine(to: CGPoint(x: width, y: centerY))
            context.stroke(linePath, with: .color(accentColor.opacity(0.5)), lineWidth: 2.0)
        }
        .frame(width: viewWidth, height: viewHeight)
    }
}
