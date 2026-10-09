import CoreLocation
import Foundation
import Weather
import WeatherKit

/// Forecasts recorded from WeatherKit, for tests and previews. They are decoded and converted the
/// same way as live data, so they show what WeatherKit really returns.
///
/// Recorded with `WeatherService.weather(for:including:)` for ten days and their hours. The hours
/// start at midnight of the time zone the recording was made in: Japan's for Tokyo and Singapore,
/// Los Angeles' for Los Angeles.
public enum WeatherRecording: String, CaseIterable, Sendable {
  /// Minato, Tokyo, recorded on 8 October 2026 (JST): mostly clear and clear days, then drizzle.
  case tokyo
  /// Singapore, recorded on 8 October 2026 (JST): rain and drizzle every day, so no day is sunny.
  case singapore
  /// Los Angeles, recorded on 8 October 2026 (PDT): two clear days, clouds, rain and drizzle, then
  /// clear again. For the English screenshots, with the simulator in Los Angeles' time zone.
  case losAngeles

  /// Where the recording was made.
  public var coordinate: CLLocationCoordinate2D {
    switch self {
    case .tokyo: CLLocationCoordinate2D(latitude: 35.658, longitude: 139.751)
    case .singapore: CLLocationCoordinate2D(latitude: 1.290, longitude: 103.852)
    case .losAngeles: CLLocationCoordinate2D(latitude: 34.052, longitude: -118.244)
    }
  }

  /// The recording made closest to `coordinate`.
  public static func nearest(to coordinate: CLLocationCoordinate2D) -> WeatherRecording {
    allCases.min { a, b in
      a.squaredDistance(to: coordinate) < b.squaredDistance(to: coordinate)
    }!
  }

  private func squaredDistance(to other: CLLocationCoordinate2D) -> Double {
    let dLatitude = coordinate.latitude - other.latitude
    let dLongitude = coordinate.longitude - other.longitude
    return dLatitude * dLatitude + dLongitude * dLongitude
  }

  /// The recording, moved by whole days so that its first day starts on `day`, and expiring
  /// `expirationDate`.
  public func forecast(
    startingOn day: Date = .now, expiringAt expirationDate: Date = .now.addingTimeInterval(60 * 60),
    calendar: Calendar = .current
  ) -> WeatherForecast {
    var forecast = recorded
    guard let firstDay = forecast.daily.first?.date else { return forecast }
    let offset = calendar.startOfDay(for: day).timeIntervalSince(firstDay)
    for index in forecast.daily.indices {
      forecast.daily[index].date += offset
      forecast.daily[index].sunrise? += offset
      forecast.daily[index].sunset? += offset
    }
    for index in forecast.hourly.indices {
      forecast.hourly[index].date += offset
    }
    forecast.expirationDate = expirationDate
    return forecast
  }

  /// The recording as WeatherKit returned it.
  public var recorded: WeatherForecast {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    do {
      return WeatherForecast(
        daily: try decoder.decode(Forecast<DayWeather>.self, from: data("daily")),
        hourly: try decoder.decode(Forecast<HourWeather>.self, from: data("hourly"))
      )
    } catch {
      fatalError("The \(rawValue) recording can't be decoded: \(error)")
    }
  }

  /// Read from the source folder, not from a bundle, so that an app linking this module for its
  /// previews doesn't ship the recordings. Tests and previews run on the Mac or a simulator,
  /// which can read the source folder.
  private func data(_ kind: String) -> Data {
    let url = URL(filePath: #filePath)
      .deletingLastPathComponent()
      .appending(path: "Recordings/\(rawValue)-\(kind).json")
    guard let data = try? Data(contentsOf: url) else {
      fatalError("The \(rawValue)-\(kind) recording is missing at \(url.path()).")
    }
    return data
  }
}
