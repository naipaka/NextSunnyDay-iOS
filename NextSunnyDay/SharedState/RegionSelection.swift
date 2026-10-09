import Forecast
import Foundation
import Observation
import Region
import WidgetKit

/// The user's regions (up to three) and the one Home shows. Empty until they choose one, which
/// shows onboarding.
@Observable
final class RegionSelection {
  private(set) var list: RegionList

  @ObservationIgnored private let store: RegionStore
  @ObservationIgnored private let search: RegionSearch
  @ObservationIgnored private let forecastUpdater: ForecastUpdater

  init(store: RegionStore, search: RegionSearch, forecastUpdater: ForecastUpdater) {
    self.store = store
    self.search = search
    self.forecastUpdater = forecastUpdater
    list = store.loadList()
  }

  /// The region Home shows.
  var region: SavedRegion? { list.selected }
  var regions: [SavedRegion] { list.regions }

  /// Adds the place a search result stands for and chooses it.
  func add(_ candidate: RegionCandidate) async throws {
    let region = try await search.region(for: candidate)
    update { $0.add(region) }
  }

  /// Adds the device location, found each time the forecast is fetched, and chooses it.
  func addCurrentLocation() {
    update { $0.add(.currentLocation) }
  }

  /// Chooses a saved region for Home.
  func select(_ region: SavedRegion) {
    update { $0.select(region.id) }
  }

  /// Removes regions and their cached forecasts.
  func remove(atOffsets offsets: IndexSet) {
    update { $0.remove(atOffsets: offsets) }
    let kept = Set(list.regions.map(\.id))
    Task { await forecastUpdater.removeForecasts(except: kept) }
  }

  func move(fromOffsets offsets: IndexSet, toOffset destination: Int) {
    update { $0.move(fromOffsets: offsets, toOffset: destination) }
  }

  /// Saves the change and reloads the widgets, which show the regions by their order.
  private func update(_ change: (inout RegionList) -> Void) {
    var list = list
    change(&list)
    guard list != self.list else { return }
    let regionsChanged = list.regions != self.list.regions
    self.list = list
    store.save(list)
    if regionsChanged {
      WidgetCenter.shared.reloadAllTimelines()
    }
  }
}
