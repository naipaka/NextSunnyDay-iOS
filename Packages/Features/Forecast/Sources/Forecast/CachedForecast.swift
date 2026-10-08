public import CoreLocation
public import Foundation
public import Weather

/// The last forecast fetched for a region, with where and when it was fetched.
public struct CachedForecast: Codable, Equatable, Sendable {
  /// The region it belongs to. Regions are fixed by ID, not by coordinate.
  public var regionID: String
  /// The place's name when it was fetched; for the current location, the reverse geocoded name.
  public var placeName: String?
  public var latitude: Double
  public var longitude: Double
  public var fetchedAt: Date
  public var forecast: WeatherForecast

  public init(
    regionID: String, placeName: String?, coordinate: CLLocationCoordinate2D, fetchedAt: Date,
    forecast: WeatherForecast
  ) {
    self.regionID = regionID
    self.placeName = placeName
    self.latitude = coordinate.latitude
    self.longitude = coordinate.longitude
    self.fetchedAt = fetchedAt
    self.forecast = forecast
  }

  public var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }

  /// Whether it can still be shown without fetching again: the weather service's expiration has
  /// not passed, and it was fetched today, so that "today" is right after midnight.
  public func isFresh(at now: Date, calendar: Calendar = .current) -> Bool {
    now < forecast.expirationDate && calendar.isDate(fetchedAt, inSameDayAs: now)
  }
}
