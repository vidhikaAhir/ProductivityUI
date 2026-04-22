import SwiftUI

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    let dots: [Color]

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(textColor)
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(isSelected ? AppTheme.accent : .clear)
                )

            HStack(spacing: 3) {
                ForEach(Array(dots.enumerated()), id: \.offset) { _, color in
                    Circle()
                        .fill(color)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: 6)
        }
        .frame(maxWidth: .infinity, minHeight: 44)
    }

    private var textColor: Color {
        if !isCurrentMonth { return .secondary.opacity(0.5) }
        return isSelected ? .white : .primary
    }
}
