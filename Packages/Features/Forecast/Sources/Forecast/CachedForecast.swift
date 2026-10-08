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

  /// The hour the daily fetch is due: a forecast fetched since the last 4:00 is fresh for the
  /// rest of that day (ADR 0006). Early enough that the day's forecast is in place before people
  /// check it in the morning.
  public static let dailyFetchHour = 4

  /// Whether it can be shown without fetching again: it was fetched since the last 4:00. Crossing
  /// midnight doesn't matter, because the cache already holds the next days.
  public func isFresh(at now: Date, calendar: Calendar = .current) -> Bool {
    fetchedAt >= Self.lastDailyFetchTime(atOrBefore: now, calendar: calendar)
  }

  /// Whether the weather service's expiration has passed. Pull to refresh only fetches after it.
  public func isExpired(at now: Date) -> Bool {
    now >= forecast.expirationDate
  }

  /// The last 4:00 at or before `now`.
  public static func lastDailyFetchTime(atOrBefore now: Date, calendar: Calendar = .current)
    -> Date
  {
    let today = fetchTime(on: now, calendar: calendar)
    return today <= now ? today : fetchTime(on: day(-1, from: now, calendar), calendar: calendar)
  }

  /// The first 4:00 after `now`.
  public static func nextDailyFetchTime(after now: Date, calendar: Calendar = .current) -> Date {
    let today = fetchTime(on: now, calendar: calendar)
    return today > now ? today : fetchTime(on: day(1, from: now, calendar), calendar: calendar)
  }

  private static func fetchTime(on day: Date, calendar: Calendar) -> Date {
    calendar.date(bySettingHour: dailyFetchHour, minute: 0, second: 0, of: day)
      ?? calendar.startOfDay(for: day)
  }

  private static func day(_ offset: Int, from date: Date, _ calendar: Calendar) -> Date {
    calendar.date(byAdding: .day, value: offset, to: date) ?? date
  }
}
