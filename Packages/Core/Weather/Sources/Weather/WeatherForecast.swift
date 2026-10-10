import Foundation

/// The forecast of one place: ten days, and the hours of the same days.
public struct WeatherForecast: Codable, Equatable, Sendable {
  /// One entry per day, starting today.
  public var daily: [DayForecast]
  /// One entry per hour, from midnight today to the end of the last day in `daily`.
  public var hourly: [HourForecast]
  /// When the data should be fetched again, as given by the weather service.
  public var expirationDate: Date

  public init(daily: [DayForecast], hourly: [HourForecast], expirationDate: Date) {
    self.daily = daily
    self.hourly = hourly
    self.expirationDate = expirationDate
  }

  /// The days from `today` on. A forecast kept past midnight still starts with the days before.
  public func days(from today: Date, calendar: Calendar = .current) -> [DayForecast] {
    let start = calendar.startOfDay(for: today)
    return daily.filter { calendar.startOfDay(for: $0.date) >= start }
  }
}

/// The forecast of one day.
public struct DayForecast: Codable, Equatable, Sendable {
  /// The start of the day in the place's time zone.
  public var date: Date
  public var condition: WeatherCondition
  /// An SF Symbol name for the condition, such as `cloud.sun`.
  public var symbolName: String
  public var highTemperature: Measurement<UnitTemperature>
  public var lowTemperature: Measurement<UnitTemperature>
  /// The chance of precipitation, from 0 to 1.
  public var precipitationChance: Double
  /// `nil` when the sun doesn't rise that day (polar night).
  public var sunrise: Date?
  /// `nil` when the sun doesn't set that day (midnight sun).
  public var sunset: Date?
  public var uvIndex: Int
  public var windSpeed: Measurement<UnitSpeed>
  /// The direction the wind blows from.
  public var windDirection: Measurement<UnitAngle>
  /// The forecast from 7:00 to 19:00.
  public var daytime: DaytimeForecast

  public init(
    date: Date, condition: WeatherCondition, symbolName: String,
    highTemperature: Measurement<UnitTemperature>, lowTemperature: Measurement<UnitTemperature>,
    precipitationChance: Double, sunrise: Date?, sunset: Date?, uvIndex: Int,
    windSpeed: Measurement<UnitSpeed>, windDirection: Measurement<UnitAngle>,
    daytime: DaytimeForecast
  ) {
    self.date = date
    self.condition = condition
    self.symbolName = symbolName
    self.highTemperature = highTemperature
    self.lowTemperature = lowTemperature
    self.precipitationChance = precipitationChance
    self.sunrise = sunrise
    self.sunset = sunset
    self.uvIndex = uvIndex
    self.windSpeed = windSpeed
    self.windDirection = windDirection
    self.daytime = daytime
  }
}

/// The forecast of a day from 7:00 to 19:00, when laundry hangs outside.
public struct DaytimeForecast: Codable, Equatable, Sendable {
  public var condition: WeatherCondition
  /// The chance of precipitation, from 0 to 1.
  public var precipitationChance: Double
  /// The lowest relative humidity, from 0 to 1.
  public var minimumHumidity: Double
  /// The highest sustained wind speed.
  public var highWindSpeed: Measurement<UnitSpeed>

  public init(
    condition: WeatherCondition, precipitationChance: Double, minimumHumidity: Double,
    highWindSpeed: Measurement<UnitSpeed>
  ) {
    self.condition = condition
    self.precipitationChance = precipitationChance
    self.minimumHumidity = minimumHumidity
    self.highWindSpeed = highWindSpeed
  }
}

/// The forecast of one hour.
public struct HourForecast: Codable, Equatable, Sendable {
  /// The start of the hour.
  public var date: Date
  public var condition: WeatherCondition
  /// An SF Symbol name for the condition, such as `cloud.moon`.
  public var symbolName: String
  public var isDaylight: Bool
  public var temperature: Measurement<UnitTemperature>
  /// The chance of precipitation, from 0 to 1.
  public var precipitationChance: Double

  public init(
    date: Date, condition: WeatherCondition, symbolName: String, isDaylight: Bool,
    temperature: Measurement<UnitTemperature>, precipitationChance: Double
  ) {
    self.date = date
    self.condition = condition
    self.symbolName = symbolName
    self.isDaylight = isDaylight
    self.temperature = temperature
    self.precipitationChance = precipitationChance
  }
}
