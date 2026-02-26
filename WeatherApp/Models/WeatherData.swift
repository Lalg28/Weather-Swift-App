import Foundation

// These are plain data models — like TypeScript interfaces/types in React.
// Swift structs are value types (copied on assignment), similar to how you'd
// treat plain objects in React state (immutable by convention).

// Think of this as: interface CurrentWeather { temperature: number; ... }
struct CurrentWeather {
    let temperature: Int
    let condition: WeatherCondition
    let high: Int
    let low: Int
    let feelsLike: Int
    let humidity: Int
    let windSpeed: Int
}

// Identifiable is like having a guaranteed `key` prop for lists.
// SwiftUI's ForEach requires each item to be uniquely identifiable,
// just like React's key={item.id} in .map() renders.
struct DayForecast: Identifiable {
    let id = UUID() // Auto-generated unique key, like crypto.randomUUID()
    let dayName: String
    let condition: WeatherCondition
    let high: Int
    let low: Int
}

// Enums in Swift are much more powerful than TS enums.
// Each case can have computed properties — think of it like a union type
// ("sunny" | "cloudy" | ...) paired with a lookup map for derived values.
enum WeatherCondition: String {
    case sunny
    case cloudy
    case rainy
    case stormy
    case snowy
    case partlyCloudy

    // Computed property — like a getter that derives a value from the enum case.
    // SF Symbols are Apple's built-in icon library, similar to react-icons or heroicons.
    var sfSymbol: String {
        switch self {
        case .sunny:       return "sun.max.fill"
        case .cloudy:      return "cloud.fill"
        case .rainy:       return "cloud.rain.fill"
        case .stormy:      return "cloud.bolt.rain.fill"
        case .snowy:       return "cloud.snow.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        }
    }

    var color: String {
        switch self {
        case .sunny:       return "yellow"
        case .cloudy:      return "gray"
        case .rainy:       return "blue"
        case .stormy:      return "purple"
        case .snowy:       return "cyan"
        case .partlyCloudy: return "orange"
        }
    }
}
