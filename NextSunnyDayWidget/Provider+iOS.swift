import CoreLocation
import Forecast
import Foundation
import Notice
import Region
import SunnyDay
import Units
import Weather

/// What the iPhone's widget does around a fetch: it looks up the current location, schedules the
/// app's notifications and shows the Apple Weather mark.
extension Provider {
  /// Where the region is now. For the current location, the widget looks the location up only
  /// while the system lets it (shortly after the widget was visible); `nil` otherwise.
  func locate(_ region: SavedRegion) async -> LocatedRegion? {
    if region.kind == .currentLocation, !CLLocationManager().isAuthorizedForWidgetUpdates {
      return nil
    }
    return try? await RegionLocator(locationTimeout: .seconds(5)).locate(region)
  }

  /// Schedules the app's notifications again when the widget fetched the region they are about,
  /// as the app does after its own fetches: the widget's daily fetch often runs when the app
  /// doesn't.
  func didFetch(_ fetched: CachedForecast, level: SunnyLevel) async {
    let setting = NoticeSettingStore().load()
    guard
      setting.isOn,
      let region = RegionStore().loadList().region(id: setting.regionID),
      region.id == fetched.regionID
    else { return }
    let unit = TemperatureUnitStore().load().unit(for: .current)
    let placeName = region.placeName ?? fetched.placeName
    let notices = setting.notices(
      in: fetched.forecast.daily, fetchedAt: fetched.fetchedAt, isSunny: level.counts)
    await NoticeScheduler().schedule(notices, regionID: region.id) { notice in
      NoticeText(notice, placeName: placeName, unit: unit, level: level)
    }
  }

  /// The Apple Weather mark for the medium and large widgets.
  func attributionMark(using updater: ForecastUpdater) async -> Data? {
    await AttributionMarkCache().mark(using: updater)
  }
}

extension NoticeText {
  /// Worded as the app words it (`NoticeSchedule.swift` in the app).
  init(_ notice: Notice, placeName: String?, unit: UnitTemperature, level: SunnyLevel) {
    let day = notice.day
    let condition = day.condition.localizedName
    let high = day.highTemperature.degrees(in: unit)
    let low = day.lowTemperature.degrees(in: unit)
    self.init(
      title: placeName ?? String(localized: "Current Location"),
      body: level == .laundry
        ? String(
          localized:
            "Good news: a laundry day tomorrow! \(condition), with a high of \(high) and a low of \(low)."
        )
        : String(
          localized:
            "Good news: sunny tomorrow! \(condition), with a high of \(high) and a low of \(low)."
        ),
      hiddenPreviewsBody: String(localized: "Tomorrow's weather"))
  }
}
