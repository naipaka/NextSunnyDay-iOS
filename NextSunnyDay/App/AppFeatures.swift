import AppGroup
import Forecast
import Notice
import Region
import SunnyDay
import SwiftUI
import Units
import WatchSync

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
  /// Copies the regions, the sunny level and the temperature unit to the watch app. `nil` in
  /// previews, which don't talk to a watch.
  var settingsSync: SettingsSync? = nil

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
      noticeScheduler: NoticeScheduler(),
      settingsSync: SettingsSync(
        mirror: SettingsMirror(
          keys: syncedKeys, defaults: AppGroupContainer.userDefaults))
    )
  }

  /// The keys of the settings copied to the watch: the regions (not the shown one, which each
  /// device keeps), the sunny level and the temperature unit.
  static let syncedKeys = [RegionStore.key, SunnyLevelStore.key, TemperatureUnitStore.key]
}

extension EnvironmentValues {
  /// Region search, called by the Region screen while the user types.
  @Entry var regionSearch = RegionSearch()
  /// What the weather data must credit, for the footers and About.
  @Entry var forecastUpdater = ForecastUpdater()
  /// Sends the settings to the watch app when they change.
  @Entry var settingsSync: SettingsSync? = nil
}
