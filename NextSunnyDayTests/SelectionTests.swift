import Foundation
import PlaceSearchTesting
import Region
import SunnyDay
import Testing

@testable import NextSunnyDay

@MainActor
struct SelectionTests {
  let defaults = UserDefaults(suiteName: "SelectionTests.\(UUID().uuidString)")!

  private func regionSelection() -> RegionSelection {
    RegionSelection(
      store: RegionStore(defaults: defaults), search: RegionSearch(places: FakePlaceSearch()))
  }

  @Test func noRegionUntilTheUserChooses() {
    #expect(regionSelection().region == nil)
  }

  @Test func aSearchResultBecomesTheStoredRegion() async throws {
    let selection = regionSelection()
    let candidate = try #require(
      try await RegionSearch(places: FakePlaceSearch()).candidates(for: "札幌").first)

    try await selection.select(candidate)

    #expect(selection.region?.placeName == "札幌市")
    #expect(regionSelection().region == selection.region)
  }

  @Test func theCurrentLocationReplacesThePlace() async throws {
    let selection = regionSelection()
    let candidate = try #require(
      try await RegionSearch(places: FakePlaceSearch()).candidates(for: "札幌").first)
    try await selection.select(candidate)

    selection.useCurrentLocation()

    #expect(selection.region == .currentLocation)
    #expect(RegionStore(defaults: defaults).load() == [.currentLocation])
  }

  @Test func theSunnyLevelIsStored() {
    let selection = SunnyLevelSelection(store: SunnyLevelStore(defaults: defaults))
    #expect(selection.level == .default)

    selection.select(.noRain)

    #expect(SunnyLevelSelection(store: SunnyLevelStore(defaults: defaults)).level == .noRain)
  }
}
