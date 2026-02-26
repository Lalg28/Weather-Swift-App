import SwiftUI

// A presentational component — like a React component that only receives props and renders UI.
// `let` properties are the "props". They're immutable and passed in by the parent.
struct CurrentWeatherView: View {
    let weather: CurrentWeather  // Props — like: function CurrentWeatherView({ weather, cityName })
    let cityName: String

    var body: some View {
        // VStack = flexbox column. All children stack vertically with 12pt spacing.
        VStack(spacing: 12) {
            Text(cityName)
                .font(.title2)
                .fontWeight(.medium)

            // Image(systemName:) loads an SF Symbol — Apple's built-in icon library.
            // .symbolRenderingMode(.multicolor) enables the icon's native colors.
            Image(systemName: weather.condition.sfSymbol)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 80)) // Icons scale with font size in SwiftUI

            // String interpolation uses \() instead of ${} in JS template literals.
            Text("\(weather.temperature)°")
                .font(.system(size: 72, weight: .thin))

            // .rawValue gets the string from the enum case ("sunny" -> "Sunny" after .capitalized)
            Text(weather.condition.rawValue.capitalized)
                .font(.title3)
                .foregroundStyle(.secondary)

            // HStack = flexbox row
            HStack(spacing: 20) {
                // Label combines an icon + text — like <span><Icon /> H: 78°</span>
                Label("H: \(weather.high)°", systemImage: "arrow.up")
                Label("L: \(weather.low)°", systemImage: "arrow.down")
            }
            .font(.callout)
            .foregroundStyle(.secondary)

            HStack(spacing: 30) {
                // Reusable sub-component, like a small <WeatherDetail /> React component.
                WeatherDetail(icon: "thermometer", label: "Feels Like", value: "\(weather.feelsLike)°")
                WeatherDetail(icon: "humidity.fill", label: "Humidity", value: "\(weather.humidity)%")
                WeatherDetail(icon: "wind", label: "Wind", value: "\(weather.windSpeed) km/h")
            }
            .padding(.top, 8)
        }
        .padding()
    }
}

// A small reusable component — like a <WeatherDetail icon="..." label="..." value="..." /> in React.
struct WeatherDetail: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
            Text(value)
                .font(.callout)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    CurrentWeatherView(
        weather: CurrentWeather(
            temperature: 72, condition: .sunny, high: 78, low: 61,
            feelsLike: 70, humidity: 45, windSpeed: 8
        ),
        cityName: "San Francisco"
    )
}
