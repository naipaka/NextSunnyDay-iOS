import Foundation
import Weather
import WeatherKit

/// Forecasts recorded from WeatherKit, for tests and previews. They are decoded and converted the
/// same way as live data, so they show what WeatherKit really returns.
///
/// Recorded on 8 October 2026 (JST) with `WeatherService.weather(for:including:)` for ten days and
/// their hours.
public enum WeatherRecording: String, CaseIterable, Sendable {
  /// Minato, Tokyo: mostly clear and clear days, then drizzle.
  case tokyo
  /// Singapore: rain and drizzle every day, so no day is sunny.
  case singapore

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
