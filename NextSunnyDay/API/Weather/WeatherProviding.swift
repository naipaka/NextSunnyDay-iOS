//
//  WeatherProviding.swift
//  NextSunnyDay
//

import CoreLocation
import WeatherKit

// MARK: - WeatherProviding
/// Fetches forecasts. Inject a fake through this protocol in tests and previews.
protocol WeatherProviding: Sendable {
  /// The daily forecast starting today and the hourly forecast for the same days.
  func forecast(for location: ForecastLocation) async throws -> ForecastSnapshot
}

// MARK: - WeatherKitProvider
/// Fetches forecasts from WeatherKit. The default daily query returns 10 days; the hourly query
/// covers the same days from midnight today.
struct WeatherKitProvider: WeatherProviding {
  private let service: WeatherService

  init(service: WeatherService = .shared) {
    self.service = service
  }

  func forecast(for location: ForecastLocation) async throws -> ForecastSnapshot {
    let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
    let now = Date()
    let startOfToday = Calendar.current.startOfDay(for: now)
    let (daily, hourly) = try await service.weather(
      for: clLocation,
      including: .daily,
      .hourly(startDate: startOfToday, endDate: startOfToday.addingTimeInterval(10 * 24 * 60 * 60))
    )
    return ForecastSnapshot(
      location: location,
      fetchedAt: now,
      daily: daily.map(DailyForecast.init),
      hourly: hourly.map(HourlyForecast.init)
    )
  }
}

extension DailyForecast {
  init(_ day: DayWeather) {
    self.init(
      date: day.date,
      condition: day.condition,
      symbolName: day.symbolName,
      highTemperature: day.highTemperature,
      lowTemperature: day.lowTemperature,
      precipitationChance: day.precipitationChance,
      sunrise: day.sun.sunrise,
      sunset: day.sun.sunset,
      uvIndex: day.uvIndex.value,
      windSpeed: day.wind.speed,
      windDirection: day.wind.direction
    )
  }
}

extension HourlyForecast {
  init(_ hour: HourWeather) {
    self.init(
      date: hour.date,
      condition: hour.condition,
      symbolName: hour.symbolName,
      isDaylight: hour.isDaylight,
      temperature: hour.temperature,
      precipitationChance: hour.precipitationChance
    )
  }
}
