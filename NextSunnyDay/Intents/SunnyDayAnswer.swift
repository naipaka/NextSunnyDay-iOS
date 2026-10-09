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
  case sunny(NextSunnyDay, placeName: String?)
  /// None of the cached days is sunny.
  case noneInRange(placeName: String?)

  /// `placeName` is `nil` only for the current location before its name is known.
  init(region: SavedRegion, forecast: CachedForecast?, level: SunnyLevel, now: Date = .now) {
    let placeName = region.placeName ?? forecast?.placeName
    let days = forecast?.forecast.days(from: now) ?? []
    if days.isEmpty {
      self = .noData
    } else if let next = level.nextSunnyDay(in: days, now: now) {
      self = .sunny(next, placeName: placeName)
    } else {
      self = .noneInRange(placeName: placeName)
    }
  }

  /// What Siri says, in the wording of Home's header and the widget.
  var dialog: LocalizedStringResource {
    switch self {
    case .noRegion:
      return "Choose a region in the app."
    case .noData:
      return "Couldn't get the weather. Try again where you have a connection."
    case .sunny(let next, let placeName):
      let place = Self.place(placeName)
      let condition = next.day.condition.localizedName
      switch next.daysAway {
      case 0:
        return "\(place) should be sunny today: \(condition)."
      case 1:
        return "\(place) should be sunny tomorrow, \(next.day.date.spokenDay): \(condition)."
      default:
        return
          "The next sunny day in \(place) is \(next.day.date.spokenDay), in \(next.daysAway) days: \(condition)."
      }
    case .noneInRange(let placeName):
      return "No sunny day in \(Self.place(placeName)) in the next 10 days."
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
  /// as Home does; when that fails, the cached one answers.
  func nextSunnyDayAnswer(regionID: String?, now: Date = .now) async -> SunnyDayAnswer {
    guard let region = regionStore.loadList().region(id: regionID) else { return .noRegion }
    let regionForecast = RegionForecast(updater: forecastUpdater, locator: regionLocator)
    await regionForecast.refreshIfNeeded(for: region)
    return SunnyDayAnswer(
      region: region, forecast: regionForecast.forecast, level: sunnyLevelStore.load(), now: now)
  }
}
