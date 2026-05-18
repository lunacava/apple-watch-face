import SwiftUI

struct VerticalTimeRuler: View {
    let date: Date
    let viewWidth: CGFloat
    let viewHeight: CGFloat
    let accentColor: Color
    var dimmed: Bool = false

    static let pixelsPerMinute: CGFloat = 1.8

    private var calendar: Calendar { Calendar.current }
    private var hour: Int { calendar.component(.hour, from: date) }
    private var minute: Int { calendar.component(.minute, from: date) }
    private var second: Int { calendar.component(.second, from: date) }

    var body: some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height
            let centerY = height / 2.0
            let rulerX = width * 0.66

            if !dimmed {
                drawTimeScale(context: context, centerY: centerY, rulerX: rulerX, width: width, height: height)
            } else {
                drawTimeScaleDimmed(context: context, centerY: centerY, rulerX: rulerX, height: height)
            }
            drawCurrentTimeLine(context: context, centerY: centerY, width: width)
        }
        .frame(width: viewWidth, height: viewHeight)
        .clipped()
    }

    private func drawRulerLine(context: GraphicsContext, x: CGFloat, height: CGFloat) {
        var path = Path()
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: height))
        context.stroke(path, with: .color(.white.opacity(0.15)), lineWidth: 1.0)
    }

    private func drawTimeScale(
        context: GraphicsContext,
        centerY: CGFloat,
        rulerX: CGFloat,
        width: CGFloat,
        height: CGFloat
    ) {
        let ppm = Self.pixelsPerMinute
        let totalMinutesVisible = Int(height / ppm) + 80
        let halfRange = totalMinutesVisible / 2
        let currentTotalMinutes = hour * 60 + minute
        let subMinuteOffset = CGFloat(second) / 60.0 * ppm

        for offsetMin in -halfRange...halfRange {
            let totalMin = currentTotalMinutes + offsetMin
            let displayHour = ((floorDiv(totalMin, 60) % 24) + 24) % 24
            let displayMin = ((totalMin % 60) + 60) % 60

            let y = centerY + CGFloat(offsetMin) * ppm - subMinuteOffset

            guard y > -120 && y < height + 120 else { continue }

            if displayMin == 0 {
                drawHourMark(context: context, y: y, hour: displayHour, rulerX: rulerX)
            } else if displayMin % 15 == 0 {
                drawQuarterMark(context: context, y: y, minute: displayMin, rulerX: rulerX)
            } else if displayMin % 5 == 0 {
                drawFiveMinTick(context: context, y: y, rulerX: rulerX)
            }
        }
    }

    private func drawTimeScaleDimmed(
        context: GraphicsContext,
        centerY: CGFloat,
        rulerX: CGFloat,
        height: CGFloat
    ) {
        let hourStr = String(format: "%02d", hour)
        let minStr = String(format: "%02d", minute)
        let hourText = Text(hourStr)
            .font(.custom("OCRAExtended", size: 82))
            .tracking(-6)
            .foregroundColor(.white.opacity(0.5))
        context.draw(
            context.resolve(hourText),
            at: CGPoint(x: rulerX - 8, y: centerY - 20),
            anchor: .trailing
        )
        let minText = Text(minStr)
            .font(.custom("OCRAExtended", size: 20))
            .tracking(-1)
            .foregroundColor(.white.opacity(0.3))
        context.draw(
            context.resolve(minText),
            at: CGPoint(x: rulerX + 7, y: centerY - 20),
            anchor: .leading
        )
    }

    private func drawHourMark(
        context: GraphicsContext,
        y: CGFloat,
        hour: Int,
        rulerX: CGFloat
    ) {
        var linePath = Path()
        linePath.move(to: CGPoint(x: rulerX - 6, y: y))
        linePath.addLine(to: CGPoint(x: rulerX + 6, y: y))
        context.stroke(linePath, with: .color(.white.opacity(0.5)), lineWidth: 1.5)

        let hourStr = String(format: "%02d", hour)
        let hourText = Text(hourStr)
            .font(.custom("OCRAExtended", size: 82))
            .tracking(-6)
            .foregroundColor(.white)
        context.draw(
            context.resolve(hourText),
            at: CGPoint(x: rulerX - 8, y: y),
            anchor: .trailing
        )
    }

    private func drawQuarterMark(
        context: GraphicsContext,
        y: CGFloat,
        minute: Int,
        rulerX: CGFloat
    ) {
        var linePath = Path()
        linePath.move(to: CGPoint(x: rulerX - 4, y: y))
        linePath.addLine(to: CGPoint(x: rulerX + 4, y: y))
        context.stroke(linePath, with: .color(.white.opacity(0.4)), lineWidth: 1.0)

        let minText = Text(String(minute))
            .font(.custom("OCRAExtended", size: 20))
            .tracking(-1)
            .foregroundColor(.white.opacity(0.6))
        context.draw(
            context.resolve(minText),
            at: CGPoint(x: rulerX + 7, y: y),
            anchor: .leading
        )
    }

    private func drawFiveMinTick(
        context: GraphicsContext,
        y: CGFloat,
        rulerX: CGFloat
    ) {
        var dotPath = Path()
        dotPath.addEllipse(in: CGRect(x: rulerX - 1.5, y: y - 1.5, width: 3, height: 3))
        context.fill(dotPath, with: .color(.white.opacity(0.2)))
    }

    private func drawCurrentTimeLine(context: GraphicsContext, centerY: CGFloat, width: CGFloat) {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: centerY))
        path.addLine(to: CGPoint(x: width, y: centerY))
        context.stroke(path, with: .color(accentColor.opacity(0.8)), lineWidth: 1.2)
    }

    private func floorDiv(_ a: Int, _ b: Int) -> Int {
        let result = a / b
        return (a < 0 && a % b != 0) ? result - 1 : result
    }
}
