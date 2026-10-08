import Forecast
import Region
import SunnyDay
import SwiftUI

/// The features the app uses, built in one place: the real ones for the app, and ones on fakes of
/// the outside world for previews.
struct AppFeatures {
  var regionStore: RegionStore
  var regionSearch: RegionSearch
  var regionLocator: RegionLocator
  var forecastUpdater: ForecastUpdater
  var sunnyLevelStore: SunnyLevelStore

  /// WeatherKit, Core Location, MapKit and the App Group.
  static var live: AppFeatures {
    AppFeatures(
      regionStore: RegionStore(),
      regionSearch: RegionSearch(),
      regionLocator: RegionLocator(),
      forecastUpdater: ForecastUpdater(),
      sunnyLevelStore: SunnyLevelStore()
    )
  }
}

extension EnvironmentValues {
  /// Region search, called by the Region screen while the user types.
  @Entry var regionSearch = RegionSearch()
  /// What the weather data must credit, for the footers and About.
  @Entry var forecastUpdater = ForecastUpdater()
}
