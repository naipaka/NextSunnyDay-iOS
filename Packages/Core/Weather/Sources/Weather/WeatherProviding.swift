public import CoreLocation

/// Fetches forecasts and the attribution. `WeatherKitProvider` is the real one; `WeatherTesting`
/// has a fake.
public protocol WeatherProviding: Sendable {
  /// Ten days from today, and their hours.
  func forecast(for coordinate: CLLocationCoordinate2D) async throws -> WeatherForecast
  func attribution() async throws -> WeatherDataAttribution
}
