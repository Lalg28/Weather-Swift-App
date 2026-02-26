import Foundation

// MARK: - Open-Meteo API Response
// These Codable structs define the shape of the JSON response — like a TypeScript interface
// for your fetch() response. Swift uses Codable to auto-parse JSON into typed structs,
// similar to zod schemas or manual typing with `as MyType` in TypeScript.

struct OpenMeteoResponse: Codable {
    let current: CurrentData
    let daily: DailyData

    struct CurrentData: Codable {
        let temperature2m: Double
        let relativeHumidity2m: Int
        let apparentTemperature: Double
        let weatherCode: Int
        let windSpeed10m: Double

        // CodingKeys map JSON snake_case keys to Swift camelCase properties.
        // Like a custom deserializer — the API returns "temperature_2m" but
        // we access it as temperature2m in code.
        enum CodingKeys: String, CodingKey {
            case temperature2m = "temperature_2m"
            case relativeHumidity2m = "relative_humidity_2m"
            case apparentTemperature = "apparent_temperature"
            case weatherCode = "weather_code"
            case windSpeed10m = "wind_speed_10m"
        }
    }

    struct DailyData: Codable {
        let time: [String]
        let weatherCode: [Int]
        let temperature2mMax: [Double]
        let temperature2mMin: [Double]

        enum CodingKeys: String, CodingKey {
            case time
            case weatherCode = "weather_code"
            case temperature2mMax = "temperature_2m_max"
            case temperature2mMin = "temperature_2m_min"
        }
    }
}

// MARK: - Weather Service

// @MainActor ensures all property updates happen on the main thread (UI thread).
// In React, setState is always safe to call from anywhere. In Swift, you must
// explicitly guarantee UI state changes happen on the main thread — @MainActor does this.
//
// This class is like a custom hook (useWeather) + its internal state.
// ObservableObject + @Published = a reactive store that triggers re-renders.
@MainActor
class WeatherService: ObservableObject {
    // @Published properties are like useState() values.
    // When any of these change, every view using this service re-renders automatically.
    @Published var current: CurrentWeather?  // nil = not loaded yet (like undefined initial state)
    @Published var forecast: [DayForecast] = []
    @Published var isLoading = false         // Loading state — like const [loading, setLoading] = useState(false)
    @Published var errorMessage: String?

    // async function — like an async function in JS. Called with `await`.
    // This is the equivalent of a fetch() call in a useEffect or React Query's queryFn.
    func fetchWeather(latitude: Double, longitude: Double) async {
        isLoading = true
        errorMessage = nil

        // URLComponents is like the URL constructor in JS: new URL("https://...")
        // queryItems are like url.searchParams.append("key", "value")
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m"),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min"),
            URLQueryItem(name: "temperature_unit", value: "celsius"),
            URLQueryItem(name: "wind_speed_unit", value: "kmh"),
            URLQueryItem(name: "timezone", value: "auto"),
        ]

        // do/catch is Swift's try/catch — same concept as JS.
        do {
            // URLSession.shared.data() is like fetch() in JavaScript.
            // `try await` = awaits the async call and throws if it fails.
            let (data, _) = try await URLSession.shared.data(from: components.url!)

            // JSONDecoder().decode() is like response.json() but with type validation.
            // It parses the raw Data into our OpenMeteoResponse struct automatically.
            let response = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)

            // Transform API response into our app's data model.
            // Like mapping an API response to your component's state shape.
            current = CurrentWeather(
                temperature: Int(response.current.temperature2m.rounded()),
                condition: weatherCondition(from: response.current.weatherCode),
                high: Int(response.daily.temperature2mMax[0].rounded()),
                low: Int(response.daily.temperature2mMin[0].rounded()),
                feelsLike: Int(response.current.apparentTemperature.rounded()),
                humidity: response.current.relativeHumidity2m,
                windSpeed: Int(response.current.windSpeed10m.rounded())
            )

            // DateFormatter is like Intl.DateTimeFormat or dayjs/date-fns formatting.
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "yyyy-MM-dd"

            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "EEE" // "Mon", "Tue", etc.

            // enumerated() gives (index, element) pairs — like .map((item, index) => ...) in JS.
            // compactMap is like .map().filter(Boolean) — maps and removes nils.
            // Skip today (index 0), take next 5 days
            forecast = response.daily.time.enumerated().compactMap { index, dateString in
                guard index > 0, index <= 5,
                      let date = dayFormatter.date(from: dateString) else { return nil }
                return DayForecast(
                    dayName: displayFormatter.string(from: date),
                    condition: weatherCondition(from: response.daily.weatherCode[index]),
                    high: Int(response.daily.temperature2mMax[index].rounded()),
                    low: Int(response.daily.temperature2mMin[index].rounded())
                )
            }
        } catch {
            errorMessage = "Failed to load weather data"
        }

        isLoading = false
    }

    // Maps WMO weather codes (international standard) to our app's WeatherCondition enum.
    // Like a lookup function: const getCondition = (code: number): WeatherCondition => ...
    private func weatherCondition(from code: Int) -> WeatherCondition {
        switch code {
        case 0:
            return .sunny
        case 1, 2:
            return .partlyCloudy
        case 3:
            return .cloudy
        case 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82:
            return .rainy
        case 71, 73, 75, 77, 85, 86:
            return .snowy
        case 95, 96, 99:
            return .stormy
        default:
            return .cloudy
        }
    }
}
