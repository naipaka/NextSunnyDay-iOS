import Forecast
import Foundation
import Region
import SunnyDay
import Weather

/// What Siri and Shortcuts answer when asked for the next sunny day.
enum SunnyDayAnswer: Equatable {
  /// No region saved yet.
  case noRegion
  /// No forecast from today on: nothing was fetched, or only days that have passed.
  case noData
  /// `today` is today's forecast, shown beside the answer. `level` names the answer: the next
  /// sunny day or the next laundry day.
  case sunny(NextSunnyDay, placeName: String?, today: DayForecast?, level: SunnyLevel)
  /// None of the cached days is sunny.
  case noneInRange(placeName: String?, today: DayForecast?, level: SunnyLevel)

  /// `placeName` is `nil` only for the current location before its name is known.
  init(region: SavedRegion, forecast: CachedForecast?, level: SunnyLevel, now: Date = .now) {
    let placeName = region.placeName ?? forecast?.placeName
    let days = forecast?.forecast.days(from: now) ?? []
    let today = days.first.flatMap {
      Calendar.current.isDate($0.date, inSameDayAs: now) ? $0 : nil
    }
    if days.isEmpty {
      self = .noData
    } else if let next = level.nextSunnyDay(in: days, now: now) {
      self = .sunny(next, placeName: placeName, today: today, level: level)
    } else {
      self = .noneInRange(placeName: placeName, today: today, level: level)
    }
  }

  /// What Siri says, in the wording of Home's header and the widget.
  var dialog: LocalizedStringResource {
    switch self {
    case .noRegion:
      return "Choose a region in the app."
    case .noData:
      return "Couldn't get the weather. Try again where you have a connection."
    case .sunny(let next, let placeName, _, let level):
      let place = Self.place(placeName)
      let day = next.day.date.spokenDay
      let condition = next.day.condition.localizedName
      switch (next.daysAway, level) {
      case (1, .laundry):
        return "\(place) should be a laundry day tomorrow, \(day): \(condition)."
      case (1, _):
        return "\(place) should be sunny tomorrow, \(day): \(condition)."
      case (_, .laundry):
        return
          "The next laundry day in \(place) is \(day), in \(next.daysAway) days: \(condition)."
      default:
        return "The next sunny day in \(place) is \(day), in \(next.daysAway) days: \(condition)."
      }
    case .noneInRange(let placeName, _, let level):
      return level == .laundry
        ? "No laundry day in \(Self.place(placeName)) in the next 10 days."
        : "No sunny day in \(Self.place(placeName)) in the next 10 days."
    }
  }

  private static func place(_ name: String?) -> String {
    name ?? String(localized: "Current Location")
  }
}

extension Date {
  /// The day as it is spoken, such as "Saturday, October 10".
  fileprivate var spokenDay: String {
    formatted(.dateTime.weekday(.wide).month(.wide).day())
  }
}

extension AppFeatures {
  /// The answer for a saved region, or for the first one when `regionID` is `nil` or the region
  /// was removed (the widget's rule, ADR 0007). The forecast is fetched first when it isn't fresh,
  /// as Home does; when that fails, the cached one answers. The notifications are scheduled
  /// again afterwards.
  func nextSunnyDayAnswer(regionID: String?, now: Date = .now) async -> SunnyDayAnswer {
    guard let region = regionStore.loadList().region(id: regionID) else { return .noRegion }
    let regionForecast = RegionForecast(updater: forecastUpdater, locator: regionLocator)
    await regionForecast.refreshIfNeeded(for: region)
    // A fetch may have changed the forecast the notifications come from.
    await scheduleNotices(now: now)
    return SunnyDayAnswer(
      region: region, forecast: regionForecast.forecast, level: sunnyLevelStore.load(), now: now)
  }
}
