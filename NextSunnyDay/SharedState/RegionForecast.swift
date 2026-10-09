import Forecast
import Foundation
import Observation
import Region
import WidgetKit

/// The forecast of the region Home shows and how its last fetch went. Other regions keep their
/// cached forecasts for when they are shown.
///
/// Views say when to fetch (Home's `task(id:)`, pull to refresh, retry buttons); this decides how:
/// show the cache, fetch when it is stale, keep it when a fetch fails.
@Observable
final class RegionForecast {
  /// Why the last fetch failed.
  enum Failure: Equatable {
    /// The network or the weather service.
    case fetch
    /// The current location is chosen, but the app may not use the location.
    case locationDenied
    /// The current location is chosen, but the device couldn't find it.
    case locationUnavailable
  }

  /// The last forecast fetched for the selected region, kept when a later fetch fails.
  private(set) var forecast: CachedForecast?
  /// Set when the last fetch failed; cleared by the next success or by another region.
  private(set) var failure: Failure?
  var isLoading: Bool { loadingCount > 0 }

  private var loadingCount = 0
  @ObservationIgnored private let updater: ForecastUpdater
  @ObservationIgnored private let locator: RegionLocator

  init(updater: ForecastUpdater, locator: RegionLocator) {
    self.updater = updater
    self.locator = locator
  }

  /// Shows the region's cached forecast at once, so that a screen has it in its first frame and
  /// shows loading only when nothing is cached.
  func showCached(for region: SavedRegion) {
    let cached = updater.cached(regionID: region.id)
    if forecast?.regionID != region.id {
      failure = nil
    }
    // The widget may have fetched a newer one in the meantime.
    if let cached, cached.fetchedAt >= forecast?.fetchedAt ?? .distantPast {
      forecast = cached
    } else if forecast?.regionID != region.id {
      forecast = nil
    }
  }

  /// Shows the region's cached forecast, then fetches when it is missing or not fetched since the
  /// last 4:00 (ADR 0006).
  func refreshIfNeeded(for region: SavedRegion) async {
    showCached(for: region)
    if let forecast, forecast.regionID == region.id, updater.isFresh(forecast) { return }
    await fetch(region)
  }

  /// For pull to refresh and the retry buttons: fetches unless the shown forecast is within the
  /// weather service's expiration and the last fetch succeeded, so that pulling again and again
  /// doesn't spend calls (ADR 0006).
  func refresh(for region: SavedRegion) async {
    if let forecast, forecast.regionID == region.id, failure == nil,
      !updater.isExpired(forecast)
    {
      return
    }
    await fetch(region)
  }

  private func fetch(_ region: SavedRegion) async {
    loadingCount += 1
    defer { loadingCount -= 1 }
    do {
      let located = try await locator.locate(region)
      let fetched = try await updater.fetch(
        regionID: region.id, placeName: located.name, coordinate: located.coordinate)
      // A newer task for another region replaced this one; its result is cached but not shown.
      guard !Task.isCancelled else { return }
      forecast = fetched
      failure = nil
      WidgetCenter.shared.reloadAllTimelines()
    } catch {
      // Cancelled when the region changes or the app leaves the foreground; not a failure.
      guard !Task.isCancelled, !(error is CancellationError) else { return }
      failure =
        switch error as? RegionLocatorError {
        case .locationDenied: .locationDenied
        case .locationUnavailable: .locationUnavailable
        case nil: .fetch
        }
    }
  }
}
