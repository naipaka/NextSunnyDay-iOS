import Forecast
import Foundation
import Observation
import Region
import WidgetKit

/// The forecast of the region the watch shows and how its last fetch went, with the iPhone app's
/// rules (its `RegionForecast`): show the cache, fetch when it wasn't fetched since the last 4:00
/// (ADR 0006), keep it when a fetch fails.
@Observable
final class WatchForecast {
  /// Why the last fetch failed.
  enum Failure: Equatable {
    /// The network or the weather service.
    case fetch
    /// The current location is chosen, but the watch app may not use the location.
    case locationDenied
    /// The current location is chosen, but the watch couldn't find it.
    case locationUnavailable
  }

  /// The last forecast fetched for the shown region, kept when a later fetch fails.
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

  /// Shows the region's cached forecast, then fetches when it is missing or not fresh.
  func refreshIfNeeded(for region: SavedRegion) async {
    showCached(for: region)
    if let forecast, forecast.regionID == region.id, updater.isFresh(forecast) { return }
    await fetch(region)
  }

  /// For the retry button: fetches unless the shown forecast is within the weather service's
  /// expiration and the last fetch succeeded.
  func refresh(for region: SavedRegion) async {
    if let forecast, forecast.regionID == region.id, failure == nil,
      !updater.isExpired(forecast)
    {
      return
    }
    await fetch(region)
  }

  private func showCached(for region: SavedRegion) {
    let cached = updater.cached(regionID: region.id)
    if forecast?.regionID != region.id {
      failure = nil
    }
    // The complications may have fetched a newer one in the meantime.
    if let cached, cached.fetchedAt >= forecast?.fetchedAt ?? .distantPast {
      forecast = cached
    } else if forecast?.regionID != region.id {
      forecast = nil
    }
  }

  private func fetch(_ region: SavedRegion) async {
    loadingCount += 1
    defer { loadingCount -= 1 }
    do {
      let located = try await locator.locate(region)
      let fetched = try await updater.fetch(
        regionID: region.id, placeName: located.name, coordinate: located.coordinate)
      guard !Task.isCancelled else { return }
      forecast = fetched
      failure = nil
      // The complications show the same cache, and use its coordinate for the current location.
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
