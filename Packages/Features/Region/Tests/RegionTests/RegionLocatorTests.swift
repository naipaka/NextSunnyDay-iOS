import CoreLocation
import Location
import LocationTesting
import PlaceSearchTesting
import Region
import Testing

struct RegionLocatorTests {
  let osaka = CLLocationCoordinate2D(latitude: 34.702, longitude: 135.496)

  @Test func aPlaceIsWhereItWasSaved() async throws {
    let locator = RegionLocator(
      location: FakeLocationProvider(error: .denied), places: FakePlaceSearch())

    let located = try await locator.locate(.place(name: "大阪駅", coordinate: osaka))

    #expect(located.name == "大阪駅")
    #expect(located.coordinate.latitude == osaka.latitude)
  }

  @Test func theCurrentLocationIsLookedUpAndNamed() async throws {
    let locator = RegionLocator(
      location: FakeLocationProvider(osaka), places: FakePlaceSearch(nameAtCoordinate: "大阪市北区"))

    let located = try await locator.locate(.currentLocation)

    #expect(located.name == "大阪市北区")
    #expect(located.coordinate.longitude == osaka.longitude)
  }

  @Test func theCurrentLocationMayHaveNoName() async throws {
    let locator = RegionLocator(
      location: FakeLocationProvider(osaka), places: FakePlaceSearch(nameAtCoordinate: nil))

    #expect(try await locator.locate(.currentLocation).name == nil)
  }

  @Test(arguments: [
    (LocationError.denied, RegionLocatorError.locationDenied),
    (.unavailable, .locationUnavailable),
  ])
  func locationErrorsAreReported(error: LocationError, expected: RegionLocatorError) async {
    let locator = RegionLocator(
      location: FakeLocationProvider(error: error), places: FakePlaceSearch())

    await #expect(throws: expected) { try await locator.locate(.currentLocation) }
  }
}
