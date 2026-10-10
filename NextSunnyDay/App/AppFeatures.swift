import Forecast
import Notice
import Region
import SunnyDay
import SwiftUI
import Units

/// The features the app uses, built in one place: the real ones for the app, and ones on fakes of
/// the outside world for previews.
struct AppFeatures {
  var regionStore: RegionStore
  var regionSearch: RegionSearch
  var regionLocator: RegionLocator
  var forecastUpdater: ForecastUpdater
  var sunnyLevelStore: SunnyLevelStore
  var temperatureUnitStore: TemperatureUnitStore
  var noticeStore: NoticeSettingStore
  var noticeScheduler: NoticeScheduler

  /// WeatherKit, Core Location, MapKit, notifications and the App Group.
  static var live: AppFeatures {
    AppFeatures(
      regionStore: RegionStore(),
      regionSearch: RegionSearch(),
      regionLocator: RegionLocator(),
      forecastUpdater: ForecastUpdater(),
      sunnyLevelStore: SunnyLevelStore(),
      temperatureUnitStore: TemperatureUnitStore(),
      noticeStore: NoticeSettingStore(),
      noticeScheduler: NoticeScheduler()
    )
  }
}

extension EnvironmentValues {
  /// Region search, called by the Region screen while the user types.
  @Entry var regionSearch = RegionSearch()
  /// What the weather data must credit, for the footers and About.
  @Entry var forecastUpdater = ForecastUpdater()
}
