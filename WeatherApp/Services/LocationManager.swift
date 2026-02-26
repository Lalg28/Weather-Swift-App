import CoreLocation

// LocationManager is like a custom hook (useLocation) that provides reactive location data.
//
// ObservableObject = a class whose @Published properties trigger re-renders,
// similar to a Zustand/Redux store or a React context value.
//
// CLLocationManagerDelegate is a "delegate pattern" — Apple's version of event callbacks.
// Instead of manager.on('locationUpdate', callback), you implement delegate methods
// that the system calls. Think of it like registering event handlers on a browser API.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    // @Published = like useState(). When these change, any SwiftUI view
    // observing this object will automatically re-render.
    @Published var cityName: String = "Locating..."
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var latitude: Double?  // nil until location is received (like undefined in TS)
    @Published var longitude: Double?

    // init() is the constructor. NSObject requires calling super.init().
    override init() {
        super.init()
        manager.delegate = self // "I'll handle the callbacks" — like addEventListener on self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer // Don't need GPS precision for weather
    }

    // Triggers the iOS "Allow location access?" permission dialog.
    // Like calling navigator.geolocation with a permission prompt.
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    // MARK: - CLLocationManagerDelegate
    // These are callback methods the system invokes — like event handlers.

    // Called when the user responds to the permission dialog (allow/deny).
    // Similar to handling the result of navigator.permissions.query().
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation() // Permission granted — fetch location once
        case .denied, .restricted:
            cityName = "Location Denied"
        default:
            break
        }
    }

    // Called when the device gets a GPS fix — like the success callback
    // in navigator.geolocation.getCurrentPosition(successCallback).
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return } // guard = early return if nil
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        reverseGeocode(location)
    }

    // Error callback — like the error handler in getCurrentPosition.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cityName = "Unknown Location"
    }

    // MARK: - Reverse Geocoding

    // Converts lat/lng into a human-readable city name.
    // Like calling a reverse geocoding API (Google Maps, Mapbox), but built into iOS.
    private func reverseGeocode(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        // This is a callback-based async call (older Apple pattern, pre-async/await).
        // [weak self] prevents a memory leak — similar to cleaning up in useEffect's return.
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            // DispatchQueue.main.async = ensures UI updates happen on the main thread.
            // In React you don't worry about this because setState is always safe to call,
            // but in Swift/iOS, UI updates MUST happen on the main thread.
            DispatchQueue.main.async {
                if let city = placemarks?.first?.locality {
                    self?.cityName = city
                } else {
                    self?.cityName = "Unknown City"
                }
            }
        }
    }
}
