public import CoreLocation
public import Foundation
public import Weather

/// Fetches forecasts and keeps them in the cache: what the app and the widget use to show a
/// region's forecast and decide when to fetch again.
public struct ForecastUpdater: Sendable {
  private let weather: any WeatherProviding
  private let cache: ForecastCache
  private let now: @Sendable () -> Date

  /// Fetches from WeatherKit into the cache shared with the widget.
  public init() {
    self.init(weather: WeatherKitProvider(), cache: ForecastCache())
  }

  public init(
    weather: any WeatherProviding, cache: ForecastCache,
    now: @escaping @Sendable () -> Date = { .now }
  ) {
    self.weather = weather
    self.cache = cache
    self.now = now
  }

  /// The region's cached forecast, fresh or not.
  public func cached(regionID: String) async -> CachedForecast? {
    await cache.load(regionID: regionID)
  }

  /// Whether `forecast` is still fresh now.
  public func isFresh(_ forecast: CachedForecast, calendar: Calendar = .current) -> Bool {
    forecast.isFresh(at: now(), calendar: calendar)
  }

  /// Whether the weather service's expiration of `forecast` has passed.
  public func isExpired(_ forecast: CachedForecast) -> Bool {
    forecast.isExpired(at: now())
  }

  /// When the next daily fetch is due.
  public func nextDailyFetchTime(calendar: Calendar = .current) -> Date {
    CachedForecast.nextDailyFetchTime(after: now(), calendar: calendar)
  }

  /// Fetches the forecast for `coordinate`, caches it for the region and returns it.
  public func fetch(
    regionID: String, placeName: String?, coordinate: CLLocationCoordinate2D
  ) async throws -> CachedForecast {
    let forecast = try await weather.forecast(for: coordinate)
    let cached = CachedForecast(
      regionID: regionID, placeName: placeName, coordinate: coordinate, fetchedAt: now(),
      forecast: forecast)
    try await cache.save(cached)
    return cached
  }

  /// Deletes the cached forecasts of regions that were removed.
  public func removeForecasts(except regionIDs: Set<String>) async {
    await cache.removeAll(except: regionIDs)
  }

  /// What the weather data must credit.
  public func attribution() async throws -> WeatherDataAttribution {
    try await weather.attribution()
  }
}
