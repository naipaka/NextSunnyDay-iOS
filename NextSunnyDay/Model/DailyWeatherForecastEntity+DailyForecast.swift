//
//  DailyWeatherForecastEntity+DailyForecast.swift
//  NextSunnyDay
//

import Foundation
import WeatherKit

// Temporary bridge between the domain model and the Realm entity, so the current UI keeps
// working on WeatherKit data. Delete this file together with Realm in #94.
//
// `Weather.main` stores the `WeatherCondition` raw value and `Weather.icon` the SF Symbol name.
// Temperatures are stored in degrees Celsius.

extension DailyWeatherForecastEntity {
  convenience init(location: ForecastLocation, forecasts: [DailyForecast]) {
    self.init()
    cityName = location.name
    lat = location.latitude
    lon = location.longitude
    daily.append(objectsIn: forecasts.map(Daily.init))
  }

  var location: ForecastLocation {
    ForecastLocation(name: cityName, latitude: lat, longitude: lon)
  }

  /// The stored days as domain values. Days saved by version 1 (OpenWeather) are skipped.
  var dailyForecasts: [DailyForecast] {
    daily.compactMap(\.dailyForecast)
  }

  /// Sample data for previews and the widget placeholder.
  static var defaultEntity: DailyWeatherForecastEntity {
    DailyWeatherForecastEntity(
      location: ForecastLocation(name: "東京駅", latitude: 35.680_959_1, longitude: 139.767_306_8),
      forecasts: [.sample(date: Date().addingTimeInterval(60 * 60 * 24), condition: .clear)]
    )
  }
}

extension Daily {
  convenience init(_ forecast: DailyForecast) {
    self.init()
    date = Int(forecast.date.timeIntervalSince1970)
    pop = forecast.precipitationChance

    let temp = Temp()
    temp.max = forecast.highTemperature.converted(to: .celsius).value
    temp.min = forecast.lowTemperature.converted(to: .celsius).value
    self.temp = temp

    let weather = Weather()
    weather.main = forecast.condition.rawValue
    weather.weatherDescription = forecast.condition.description
    weather.icon = forecast.symbolName
    self.weather.append(weather)
  }

  var dailyForecast: DailyForecast? {
    guard let weather = weather.first, let condition = WeatherCondition(rawValue: weather.main)
    else { return nil }
    return DailyForecast(
      date: Date(timeIntervalSince1970: TimeInterval(date)),
      condition: condition,
      symbolName: weather.icon,
      highTemperature: Measurement(value: temp?.max ?? 0, unit: .celsius),
      lowTemperature: Measurement(value: temp?.min ?? 0, unit: .celsius),
      precipitationChance: pop
    )
  }
}
