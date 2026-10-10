import Forecast
import Foundation
import Region
import RegionIntents
import SunnyDay
import WidgetKit

/// What the watch's complications do around a fetch.
extension Provider {
  /// Where the region is now. A watch widget can't ask for the location (watchOS has no
  /// `isAuthorizedForWidgetUpdates`), so for the current location it is `nil`, and the fetch uses
  /// where the watch app last found it.
  func locate(_ region: SavedRegion) async -> LocatedRegion? {
    guard region.kind != .currentLocation else { return nil }
    return try? await RegionLocator().locate(region)
  }

  /// Notifications come from the iPhone; the watch shows them.
  func didFetch(_ fetched: CachedForecast, level: SunnyLevel) async {}

  /// The complications don't show the mark; the watch app does.
  func attributionMark(using updater: ForecastUpdater) async -> Data? {
    nil
  }

  /// watchOS has no Edit Widget screen: the face's editor lists one complication per saved
  /// region instead.
  func recommendations() -> [AppIntentRecommendation<SelectRegionIntent>] {
    let regions = RegionStore().load()
    guard !regions.isEmpty else {
      return [
        AppIntentRecommendation(
          intent: SelectRegionIntent(), description: String(localized: "Next Sunny Day"))
      ]
    }
    return regions.map { region in
      let intent = SelectRegionIntent()
      intent.region = RegionEntity(region)
      return AppIntentRecommendation(
        intent: intent,
        description: region.placeName ?? String(localized: "Current Location"))
    }
  }
}
