public import CoreLocation
package import WeatherKit

/// Fetches from WeatherKit. Needs the WeatherKit entitlement and network access.
public struct WeatherKitProvider: WeatherProviding {
  public init() {}

  public func forecast(for coordinate: CLLocationCoordinate2D) async throws -> WeatherForecast {
    let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    let startOfToday = Calendar.current.startOfDay(for: .now)
    // The default daily query returns ten days; the hours cover the same days.
    let (daily, hourly) = try await WeatherService.shared.weather(
      for: location,
      including: .daily,
      .hourly(startDate: startOfToday, endDate: startOfToday.addingTimeInterval(10 * 24 * 60 * 60))
    )
    return WeatherForecast(daily: daily, hourly: hourly)
  }

  public func attribution() async throws -> WeatherDataAttribution {
    let attribution = try await WeatherService.shared.attribution
    return WeatherDataAttribution(
      serviceName: attribution.serviceName,
      legalPageURL: attribution.legalPageURL,
      combinedMarkLightURL: attribution.combinedMarkLightURL,
      combinedMarkDarkURL: attribution.combinedMarkDarkURL
    )
  }
}

// MARK: - From WeatherKit

extension WeatherForecast {
  /// Converts WeatherKit's forecasts. `package` so that `WeatherTesting` converts recorded data
  /// the same way.
  package init(daily: Forecast<DayWeather>, hourly: Forecast<HourWeather>) {
    self.init(
      daily: daily.map(DayForecast.init),
      hourly: hourly.map(HourForecast.init),
      expirationDate: min(daily.metadata.expirationDate, hourly.metadata.expirationDate)
    )
  }
}

extension DayForecast {
  init(_ day: DayWeather) {
    self.init(
      date: day.date,
      condition: WeatherCondition(day.condition),
      symbolName: day.symbolName,
      highTemperature: day.highTemperature,
      lowTemperature: day.lowTemperature,
      precipitationChance: day.precipitationChance,
      sunrise: day.sun.sunrise,
      sunset: day.sun.sunset,
      uvIndex: day.uvIndex.value,
      windSpeed: day.wind.speed,
      windDirection: day.wind.direction,
      daytime: DaytimeForecast(day.daytimeForecast)
    )
  }
}

extension DaytimeForecast {
  init(_ part: DayPartForecast) {
    self.init(
      condition: WeatherCondition(part.condition),
      precipitationChance: part.precipitationChance,
      minimumHumidity: part.minimumHumidity,
      highWindSpeed: part.highWindSpeed
    )
  }
}

extension HourForecast {
  init(_ hour: HourWeather) {
    self.init(
      date: hour.date,
      condition: WeatherCondition(hour.condition),
      symbolName: hour.symbolName,
      isDaylight: hour.isDaylight,
      temperature: hour.temperature,
      precipitationChance: hour.precipitationChance
    )
  }
}

extension WeatherCondition {
  init(_ condition: WeatherKit.WeatherCondition) {
    self = WeatherCondition(rawValue: condition.rawValue) ?? .unknown
  }

  /// The condition's name in the user's language, such as 「ほぼ快晴」, as WeatherKit words it.
  public var localizedName: String {
    WeatherKit.WeatherCondition(rawValue: rawValue)?.description ?? ""
  }
}

extension WeatherCondition {
  /// The raw values of all of WeatherKit's conditions, so tests can check that each has a case
  /// here without importing WeatherKit, whose `Weather` type hides this module's name.
  package static var weatherKitRawValues: [String] {
    WeatherKit.WeatherCondition.allCases.map(\.rawValue)
  }
}
