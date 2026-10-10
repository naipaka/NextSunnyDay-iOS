import Forecast
import Foundation
import Region
import RegionIntents
import SunnyDay
import Units
import WidgetKit

/// Builds the timeline from what the app shares in the App Group: the regions, the sunny level, the
/// temperature unit and the cached forecast of the widget's region. It fetches only when the
/// forecast wasn't fetched since the last 4:00, and reloads once a day (ADR 0006).
struct Provider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> SunnyEntry {
    .placeholder
  }

  func snapshot(for configuration: SelectRegionIntent, in context: Context) async -> SunnyEntry {
    await load(configuration, fetchingIfStale: false).entry
  }

  func timeline(for configuration: SelectRegionIntent, in context: Context) async -> Timeline<
    SunnyEntry
  > {
    let loaded = await load(configuration, fetchingIfStale: true)
    return Timeline(entries: loaded.entries, policy: loaded.policy)
  }

  private struct Loaded {
    var entry: SunnyEntry
    var policy: TimelineReloadPolicy

    /// Now, and the next midnight from the same forecast, so the day count rolls over without a
    /// reload.
    var entries: [SunnyEntry] {
      let calendar = Calendar.current
      guard
        let midnight = calendar.date(
          byAdding: .day, value: 1, to: calendar.startOfDay(for: entry.date))
      else { return [entry] }
      var atMidnight = entry
      atMidnight.date = midnight
      return [entry, atMidnight]
    }
  }

  private func load(_ configuration: SelectRegionIntent, fetchingIfStale: Bool) async -> Loaded {
    let now = Date.now
    let level = SunnyLevelStore().load()
    guard let region = RegionStore().loadList().region(id: configuration.region?.id) else {
      // The app reloads the widgets when a region is chosen.
      return Loaded(entry: SunnyEntry(date: now, level: level), policy: .never)
    }
    let updater = ForecastUpdater()
    var cached = updater.cached(regionID: region.id)
    var fetchFailed = false
    if fetchingIfStale, cached.map({ !updater.isFresh($0) }) ?? true {
      if let fetched = await fetch(region, cached: cached, updater: updater) {
        cached = fetched
        await didFetch(fetched, level: level)
      } else {
        fetchFailed = true
      }
    }
    let entry = SunnyEntry(
      date: now, region: region, cached: cached, level: level,
      temperatureUnit: TemperatureUnitStore().load().unit(for: .current),
      attributionMark: await attributionMark(using: updater))
    // A failed fetch didn't reach WeatherKit or was refused, so trying again in an hour costs
    // little. Otherwise the next fetch is due at 4:00, spread over an hour so that devices don't
    // all call WeatherKit at once.
    let reload =
      fetchFailed
      ? now.addingTimeInterval(60 * 60)
      : updater.nextDailyFetchTime().addingTimeInterval(.random(in: 0..<(60 * 60)))
    return Loaded(entry: entry, policy: .after(reload))
  }

  /// Fetches for where the region is (`locate(_:)`), or for the coordinate of the last cached
  /// forecast when the location isn't available now.
  private func fetch(
    _ region: SavedRegion, cached: CachedForecast?, updater: ForecastUpdater
  ) async -> CachedForecast? {
    let located = await locate(region)
    let placeName = located.map(\.name) ?? cached?.placeName
    guard let coordinate = located?.coordinate ?? cached?.coordinate else { return nil }
    return try? await updater.fetch(
      regionID: region.id, placeName: placeName, coordinate: coordinate)
  }
}
