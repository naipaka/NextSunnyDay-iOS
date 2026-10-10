import Forecast
import Foundation
import Notice
import Region
import SunnyDay
import Units
import Weather

extension AppFeatures {
  /// Schedules the notifications for the notified region from its cached forecast, at the sunny
  /// level and in the temperature unit the user chose, replacing the ones scheduled before. It
  /// reads everything from the stores, so it can run after any change: a fetch, a setting, the
  /// regions. The widget does the same after its daily fetch.
  func scheduleNotices(now: Date = .now) async {
    let setting = noticeStore.load()
    guard
      setting.isOn,
      let region = regionStore.loadList().region(id: setting.regionID),
      let cached = forecastUpdater.cached(regionID: region.id)
    else {
      await noticeScheduler.cancel()
      return
    }
    let level = sunnyLevelStore.load()
    let unit = temperatureUnitStore.load().unit(for: .current)
    let placeName = region.placeName ?? cached.placeName
    let notices = setting.notices(
      in: cached.forecast.daily, fetchedAt: cached.fetchedAt, now: now, isSunny: level.counts)
    await noticeScheduler.schedule(notices, regionID: region.id) { notice in
      NoticeText(notice, placeName: placeName, unit: unit, level: level)
    }
  }
}

extension NoticeText {
  /// The region's name, and tomorrow's condition and temperatures; at the laundry level it says
  /// a laundry day. The widget words it the same.
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
