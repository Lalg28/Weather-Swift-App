import SwiftUI

// ContentView is the main "page" component — like your App.tsx or a top-level route component.
// In SwiftUI, every view is a struct conforming to the View protocol (like implementing an interface).
struct ContentView: View {
    // @StateObject creates and owns a class instance — like useState() + useRef() combined.
    // It persists across re-renders and the view "subscribes" to its @Published changes.
    // Think: const locationManager = useLocationManager() where the hook manages its own state.
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherService = WeatherService()

    // `body` is like the return statement of a React functional component.
    // It's a computed property that SwiftUI calls whenever state changes (automatic re-render).
    var body: some View {
        // ScrollView = <div style={{ overflow: 'auto' }}>
        ScrollView {
            // VStack = vertical flex container (<div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>)
            VStack(spacing: 24) {
                // Conditional rendering — same concept as {isLoading ? <Spinner /> : <Content />} in JSX
                if weatherService.isLoading {
                    Spacer(minLength: 100) // Like a <div style={{ minHeight: 100 }} />
                    ProgressView("Loading weather...") // Built-in spinner component
                        .font(.title3) // Chained modifiers = like inline styles but composable
                    Spacer(minLength: 100)
                } else if let errorMessage = weatherService.errorMessage {
                    // `if let` unwraps an optional (String?) — like checking if value !== undefined
                    Spacer(minLength: 100)
                    Text(errorMessage)
                        .foregroundStyle(.secondary) // .secondary = system gray, adapts to dark mode
                    Spacer(minLength: 100)
                } else if let current = weatherService.current {
                    // Passing props to child components — same as <CurrentWeatherView weather={current} />
                    CurrentWeatherView(
                        weather: current,
                        cityName: locationManager.cityName
                    )

                    if !weatherService.forecast.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            // Label = icon + text combo. systemImage uses SF Symbols (Apple's icon set).
                            Label("5-Day Forecast", systemImage: "calendar")
                                .font(.headline)
                                .foregroundStyle(.secondary)

                            Divider() // <hr />

                            // ForEach is like {forecast.map(day => <ForecastRow key={day.id} ... />)}
                            // It requires items to be Identifiable (have a unique id), which is the key.
                            ForEach(weatherService.forecast) { day in
                                ForecastRow(forecast: day)
                                if day.id != weatherService.forecast.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .padding()
                        // .background with a material = like a frosted glass CSS backdrop-filter effect
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding()        // Adds padding on all sides (like padding: 16px)
            .padding(.top, 40) // Additional top padding (like paddingTop: 40px)
        }
        // .refreshable = native pull-to-refresh. No equivalent in web React — you'd build this
        // with a library or custom scroll handler. SwiftUI gives it for free.
        .refreshable {
            guard let lat = locationManager.latitude,
                  let lon = locationManager.longitude else { return }
            await weatherService.fetchWeather(latitude: lat, longitude: lon)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Like width: 100%, height: 100%
        .background(
            // LinearGradient = like CSS linear-gradient()
            LinearGradient(
                colors: [.blue.opacity(0.3), .cyan.opacity(0.1), .white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea() // Extends behind the notch/status bar — like a full-bleed background
        )
        .ignoresSafeArea(edges: .bottom)
        // .onAppear = like useEffect(() => { ... }, []) — runs once when the view mounts.
        .onAppear {
            locationManager.requestPermission()
        }
        // .onChange = like useEffect(() => { ... }, [locationManager.latitude])
        // Fires whenever the watched value changes. Here it triggers a fetch when location arrives.
        .onChange(of: locationManager.latitude) {
            fetchWeatherIfReady()
        }
    }

    // A private helper — like a function defined inside your component.
    // `guard let` unwraps optionals or returns early — like:
    //   if (!lat || !lon) return;
    private func fetchWeatherIfReady() {
        guard let lat = locationManager.latitude,
              let lon = locationManager.longitude else { return }
        // Task { } creates an async context — like wrapping an await call inside useEffect,
        // since Swift won't let you call async functions from synchronous code directly.
        Task {
            await weatherService.fetchWeather(latitude: lat, longitude: lon)
        }
    }
}

// #Preview is Xcode's live preview — like Storybook stories for your component.
// You can see this rendered in real-time in Xcode's canvas panel.
#Preview {
    ContentView()
}
