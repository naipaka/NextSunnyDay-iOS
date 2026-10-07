//
//  ForecastSnapshot.swift
//  NextSunnyDay
//

import Foundation

// MARK: - ForecastSnapshot
/// Everything fetched for one location at one time. It is cached as a whole and replaced as a
/// whole on the next fetch.
struct ForecastSnapshot: Codable, Equatable, Sendable {
  var location: ForecastLocation
  /// When the forecast was fetched successfully.
  var fetchedAt: Date
  /// The daily forecast, starting today.
  var daily: [DailyForecast]
  /// The hourly forecast for the days in `daily`.
  var hourly: [HourlyForecast]
}

// MARK: - Staleness
extension ForecastSnapshot {
  /// Whether the snapshot should be fetched again: it is for another location, it has no days,
  /// or its earliest day started more than `maxAge` before `now`.
  func needsRefresh(for location: ForecastLocation, now: Date, maxAge: TimeInterval) -> Bool {
    guard location == self.location, let firstDay = daily.map(\.date).min() else { return true }
    return firstDay.addingTimeInterval(maxAge) < now
  }
}

// MARK: - Sample
extension ForecastSnapshot {
  /// Sample data for previews and the widget placeholder: a cloudy day, then a clear one.
  static func sample(
    location: ForecastLocation = ForecastLocation(
      name: "東京駅", latitude: 35.680_959_1, longitude: 139.767_306_8),
    now: Date = Date()
  ) -> ForecastSnapshot {
    let today = Calendar.current.startOfDay(for: now)
    let day: TimeInterval = 60 * 60 * 24
    return ForecastSnapshot(
      location: location,
      fetchedAt: now,
      daily: [
        .sample(date: today, condition: .cloudy),
        .sample(date: today.addingTimeInterval(day), condition: .clear),
      ],
      hourly: (0..<48).map {
        .sample(
          date: today.addingTimeInterval(TimeInterval($0) * 60 * 60),
          condition: $0 < 24 ? .cloudy : .clear)
      }
    )
  }
}
