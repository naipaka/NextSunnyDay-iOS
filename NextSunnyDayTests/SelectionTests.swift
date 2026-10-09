import CoreLocation
import Forecast
import Foundation
import PlaceSearchTesting
import Region
import SunnyDay
import Testing
import Units
import WeatherTesting

@testable import NextSunnyDay

@MainActor
struct SelectionTests {
  let defaults = UserDefaults(suiteName: "SelectionTests.\(UUID().uuidString)")!
  let cache = ForecastCache(
    directory: FileManager.default.temporaryDirectory
      .appending(path: "SelectionTests-\(UUID().uuidString)", directoryHint: .isDirectory))

  private func regionSelection() -> RegionSelection {
    RegionSelection(
      store: RegionStore(defaults: defaults), search: RegionSearch(places: FakePlaceSearch()),
      forecastUpdater: ForecastUpdater(weather: FakeWeatherProvider(), cache: cache))
  }

  private func add(_ query: String, to selection: RegionSelection) async throws {
    let candidate = try #require(
      try await RegionSearch(places: FakePlaceSearch()).candidates(for: query).first)
    try await selection.add(candidate)
  }

  @Test func noRegionUntilTheUserChooses() {
    #expect(regionSelection().region == nil)
  }

  @Test func anAddedSearchResultIsChosenAndStored() async throws {
    let selection = regionSelection()

    try await add("札幌", to: selection)

    #expect(selection.region?.placeName == "札幌市")
    #expect(regionSelection().region == selection.region)
  }

  @Test func addedRegionsAreKeptInOrder() async throws {
    let selection = regionSelection()
    try await add("札幌", to: selection)

    selection.addCurrentLocation()

    #expect(selection.region == .currentLocation)
    #expect(selection.regions.map(\.placeName) == ["札幌市", nil])
    #expect(regionSelection().regions == selection.regions)
    #expect(regionSelection().region == .currentLocation)
  }

  @Test func choosingARegionIsStored() async throws {
    let selection = regionSelection()
    try await add("札幌", to: selection)
    selection.addCurrentLocation()

    selection.select(selection.regions[0])

    #expect(regionSelection().region?.placeName == "札幌市")
  }

  @Test func removingARegionDeletesItsCachedForecast() async throws {
    let selection = regionSelection()
    try await add("札幌", to: selection)
    selection.addCurrentLocation()
    for region in selection.regions {
      try await cache.save(
        CachedForecast(
          regionID: region.id, placeName: nil,
          coordinate: CLLocationCoordinate2D(latitude: 35.658, longitude: 139.751),
          fetchedAt: .now, forecast: WeatherRecording.tokyo.forecast()))
    }
    let sapporo = selection.regions[0]

    selection.remove(atOffsets: [0])

    #expect(selection.regions == [.currentLocation])
    // The cache files are removed in a task.
    for _ in 0..<100 where cache.load(regionID: sapporo.id) != nil {
      try await Task.sleep(for: .milliseconds(10))
    }
    #expect(cache.load(regionID: sapporo.id) == nil)
    #expect(cache.load(regionID: SavedRegion.currentLocationID) != nil)
  }

  @Test func theSunnyLevelIsStored() {
    let selection = SunnyLevelSelection(store: SunnyLevelStore(defaults: defaults))
    #expect(selection.level == .default)

    selection.select(.noRain)

    #expect(SunnyLevelSelection(store: SunnyLevelStore(defaults: defaults)).level == .noRain)
  }

  @Test func theTemperatureUnitIsStored() {
    let selection = TemperatureUnitSelection(store: TemperatureUnitStore(defaults: defaults))
    #expect(selection.setting == .system)

    selection.select(.fahrenheit)

    let reloaded = TemperatureUnitSelection(store: TemperatureUnitStore(defaults: defaults))
    #expect(reloaded.setting == .fahrenheit)
    #expect(reloaded.unit == .fahrenheit)
  }
}
