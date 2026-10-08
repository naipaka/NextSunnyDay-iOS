import Observation
import Region
import WidgetKit

/// The region the user chose: a searched place or the current location. `nil` until they choose,
/// which shows onboarding.
@Observable
final class RegionSelection {
  private(set) var region: SavedRegion?

  @ObservationIgnored private let store: RegionStore
  @ObservationIgnored private let search: RegionSearch

  init(store: RegionStore, search: RegionSearch) {
    self.store = store
    self.search = search
    region = store.load().first
  }

  /// Chooses the place a search result stands for.
  func select(_ candidate: RegionCandidate) async throws {
    set(try await search.region(for: candidate))
  }

  /// Chooses the device location, found each time the forecast is fetched.
  func useCurrentLocation() {
    set(.currentLocation)
  }

  /// The app keeps one region for now, so the new one replaces it.
  private func set(_ region: SavedRegion) {
    self.region = region
    store.save([region])
    WidgetCenter.shared.reloadAllTimelines()
  }
}
