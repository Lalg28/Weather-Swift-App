import SwiftUI

// This is the app entry point — like ReactDOM.createRoot() in index.tsx.
// @main tells iOS "start here", similar to how React mounts into a root element.
@main
struct WeatherApp: App {
    // `body` returns the root scene. Think of WindowGroup as your <BrowserRouter> or top-level provider.
    var body: some Scene {
        WindowGroup {
            ContentView() // The root component, like <App /> in React.
        }
    }
}
