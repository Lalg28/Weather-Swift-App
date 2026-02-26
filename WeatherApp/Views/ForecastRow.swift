import SwiftUI

// A list row component — like a <ForecastRow forecast={day} /> in React.
// Renders one day of the 5-day forecast.
struct ForecastRow: View {
    let forecast: DayForecast // Single prop, like ({ forecast }: { forecast: DayForecast })

    var body: some View {
        // HStack = flexbox row
        HStack {
            Text(forecast.dayName)
                .font(.body)
                .frame(width: 40, alignment: .leading) // Fixed width — like width: 40px; text-align: left

            Image(systemName: forecast.condition.sfSymbol)
                .symbolRenderingMode(.multicolor)
                .font(.title3)
                .frame(width: 36) // Fixed width keeps icons aligned across rows

            Spacer() // Pushes remaining content to the right — like flex: 1 or margin-left: auto

            HStack(spacing: 4) {
                Text("\(forecast.low)°")
                    .foregroundStyle(.secondary)
                    .frame(width: 36, alignment: .trailing)

                // Custom temperature bar visualization
                TemperatureBar(low: forecast.low, high: forecast.high)
                    .frame(width: 100, height: 6)

                Text("\(forecast.high)°")
                    .frame(width: 36, alignment: .leading)
            }
            .font(.callout)
        }
        .padding(.vertical, 4)
    }
}

// A custom visualization component — like building a <ProgressBar /> in React with inline styles.
// Shows a colored bar representing the temperature range within a fixed scale.
struct TemperatureBar: View {
    let low: Int
    let high: Int

    var body: some View {
        // GeometryReader gives access to the parent's size — like a useRef() + getBoundingClientRect().
        // It's how you do "responsive to container size" calculations in SwiftUI.
        GeometryReader { geo in
            // The full temperature scale: -10°C to 45°C
            let range = -10.0...45.0
            let totalSpan = range.upperBound - range.lowerBound // 55 degrees total

            // Calculate where the bar starts and ends as a 0-1 fraction.
            // Like: const leftPercent = (low - min) / (max - min)
            let lowFraction = (Double(low) - range.lowerBound) / totalSpan
            let highFraction = (Double(high) - range.lowerBound) / totalSpan

            // ZStack layers views on top of each other — like position: relative + absolute children.
            ZStack(alignment: .leading) {
                // Background track — the gray bar behind the colored portion
                Capsule() // A rounded pill shape
                    .fill(Color.gray.opacity(0.2))

                // Colored portion — shows the actual temperature range
                Capsule()
                    .fill(
                        // CSS equivalent: linear-gradient(to right, blue, green, yellow, orange)
                        LinearGradient(
                            colors: [.blue, .green, .yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    // Width = percentage of total bar. Like: width: `${(high - low) / range * 100}%`
                    .frame(width: geo.size.width * (highFraction - lowFraction))
                    // Offset = position from left. Like: left: `${lowPercent * 100}%`
                    .offset(x: geo.size.width * lowFraction)
            }
        }
    }
}

#Preview {
    List {
        ForecastRow(forecast: DayForecast(dayName: "Tue", condition: .sunny, high: 75, low: 62))
        ForecastRow(forecast: DayForecast(dayName: "Wed", condition: .rainy, high: 63, low: 55))
    }
}
