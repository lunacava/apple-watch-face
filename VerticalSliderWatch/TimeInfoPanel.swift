import SwiftUI

struct TimeInfoPanel: View {
    let date: Date
    let panelHeight: CGFloat
    var dimmed: Bool = false

    private var calendar: Calendar { Calendar.current }
    private var hour: Int { calendar.component(.hour, from: date) }
    private var minute: Int { calendar.component(.minute, from: date) }
    private var second: Int { calendar.component(.second, from: date) }

    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private var dayOfMonth: String {
        String(calendar.component(.day, from: date))
    }

    private var dayProgress: Double {
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        let totalSeconds = Double(components.hour ?? 0) * 3600
            + Double(components.minute ?? 0) * 60
            + Double(components.second ?? 0)
        return totalSeconds / 86400.0
    }

    private func dayLabel(offset: Int) -> String {
        let targetDate = calendar.date(byAdding: .day, value: offset, to: date) ?? date
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEE"
        let week = formatter.string(from: targetDate)
        let day = calendar.component(.day, from: targetDate)
        return "\(week)\(day)"
    }

    var body: some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height
            let centerY = height / 2.0
            let dayHeight = height / 3.0
            let barX = width - 3

            let todayTopY = centerY - dayHeight * dayProgress


            let range = dimmed ? 0...0 : -3...3
            for dayOffset in range {
                let dayTopY = todayTopY + CGFloat(dayOffset) * dayHeight
                let dayBottomY = dayTopY + dayHeight
                let dayMidY = (dayTopY + dayBottomY) / 2.0

                guard dayBottomY > -50 && dayTopY < height + 50 else { continue }

                if !dimmed {
                    var boundaryPath = Path()
                    boundaryPath.move(to: CGPoint(x: barX - 4, y: dayBottomY))
                    boundaryPath.addLine(to: CGPoint(x: barX + 4, y: dayBottomY))
                    context.stroke(boundaryPath, with: .color(.white.opacity(0.3)), lineWidth: 1.2)
                }


                let label = dayLabel(offset: dayOffset)
                let text = Text(label)
                    .font(.custom("OCRAExtended", size: 14))
                    .tracking(-1)
                    .foregroundColor(.white.opacity(dayOffset == 0 ? 0.65 : 0.3))
                context.draw(
                    context.resolve(text),
                    at: CGPoint(x: 4, y: dayMidY),
                    anchor: .leading
                )
            }

            if !dimmed {
                var markerPath = Path()
                markerPath.move(to: CGPoint(x: barX - 4, y: centerY))
                markerPath.addLine(to: CGPoint(x: barX + 4, y: centerY))
                context.stroke(markerPath, with: .color(.white.opacity(0.5)), lineWidth: 1.5)
            }
        }
        .frame(height: panelHeight)
    }
}
