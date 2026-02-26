# WeatherApp

A SwiftUI weather app that displays real-time weather data using the [Open-Meteo API](https://open-meteo.com/). No API key required.

## Features

- Current weather with temperature, condition, feels like, humidity, and wind speed
- 5-day forecast with temperature range visualization
- Automatic location detection with reverse geocoding
- Pull-to-refresh to reload weather data
- SF Symbols for weather condition icons

## Tech Stack

- **SwiftUI** — declarative UI framework
- **CoreLocation** — device GPS and reverse geocoding
- **Open-Meteo API** — free weather data (no API key needed)
- **URLSession** — native HTTP networking

## Project Structure

```
WeatherApp/
├── WeatherApp.swift              # App entry point
├── ContentView.swift             # Main screen, wires services to views
├── Models/
│   └── WeatherData.swift         # Data models (CurrentWeather, DayForecast, WeatherCondition)
├── Services/
│   ├── LocationManager.swift     # GPS location + reverse geocoding
│   └── WeatherService.swift      # Open-Meteo API client
└── Views/
    ├── CurrentWeatherView.swift  # Current weather display
    └── ForecastRow.swift         # Forecast row + temperature bar
```

## Requirements

- iOS 17.0+
- Xcode 15+

## Setup

1. Open `WeatherApp.xcodeproj` in Xcode
2. Select a simulator or device
3. Build and run (Cmd + R)
4. Grant location permission when prompted

## How It Works

1. On launch, the app requests location permission
2. Once granted, `LocationManager` fetches the device's GPS coordinates and resolves the city name
3. `WeatherService` calls the Open-Meteo API with those coordinates
4. The UI displays current conditions and a 5-day forecast
5. Pull down to refresh the weather data
