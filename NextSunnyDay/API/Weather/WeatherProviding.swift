//
//  WeatherProviding.swift
//  NextSunnyDay
//

import CoreLocation
import WeatherKit

// MARK: - WeatherProviding
/// Fetches forecasts. Inject a fake through this protocol in tests and previews.
protocol WeatherProviding: Sendable {
  /// The daily forecast starting today.
  func dailyForecast(for location: ForecastLocation) async throws -> [DailyForecast]
}

// MARK: - WeatherKitProvider
/// Fetches forecasts from WeatherKit. The default daily query returns 10 days.
struct WeatherKitProvider: WeatherProviding {
  private let service: WeatherService

  init(service: WeatherService = .shared) {
    self.service = service
  }

  func dailyForecast(for location: ForecastLocation) async throws -> [DailyForecast] {
    let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
    let forecast = try await service.weather(for: clLocation, including: .daily)
    return forecast.map(DailyForecast.init)
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
      precipitationChance: day.precipitationChance
    )
  }
}
