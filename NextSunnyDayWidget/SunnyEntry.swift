import Forecast
import Foundation
import Region
import SunnyDay
import Units
import Weather
import WidgetKit

/// What a widget shows at `date`: the region, its cached forecast and the sunny level.
struct SunnyEntry: TimelineEntry {
  /// What the widget says.
  enum State {
    /// No region chosen in the app yet.
    case noRegion
    /// No forecast from today on: nothing was fetched, or only days that have passed.
    case noData
    case sunny(NextSunnyDay)
    /// None of the cached days is sunny.
    case noneInRange
  }

  var date: Date
  var region: SavedRegion?
  var cached: CachedForecast?
  var level: SunnyLevel
  var temperatureUnit: UnitTemperature = TemperatureUnitSetting.default.unit(for: .current)
  /// The Apple Weather mark for dark backgrounds, as image data.
  var attributionMark: Data? = nil

  /// Nothing to show yet; the system draws it redacted.
  static let placeholder = SunnyEntry(
    date: .now, region: .currentLocation, cached: nil, level: .default)

  /// The days from the entry's date on, so an entry at midnight starts with the next day.
  var days: [DayForecast] {
    cached?.forecast.days(from: date) ?? []
  }

  /// Today's forecast, shown beside the answer.
  var today: DayForecast? {
    days.first.flatMap { Calendar.current.isDate($0.date, inSameDayAs: date) ? $0 : nil }
  }

  /// The days after today, for the large widget's list.
  var laterDays: [DayForecast] {
    days.filter { !Calendar.current.isDate($0.date, inSameDayAs: date) }
  }

  var state: State {
    guard region != nil else { return .noRegion }
    guard !days.isEmpty else { return .noData }
    return level.nextSunnyDay(in: days, now: date).map(State.sunny) ?? .noneInRange
  }

  /// A searched place's name, or the reverse geocoded name of the current location.
  var placeName: String? {
    region?.placeName ?? cached?.placeName
  }
}

extension SunnyEntry {
  init(date: Date, level: SunnyLevel) {
    self.init(date: date, region: nil, cached: nil, level: level)
  }
}
