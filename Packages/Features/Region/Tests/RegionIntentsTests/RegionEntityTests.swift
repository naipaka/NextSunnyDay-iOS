import AppIntents
import CoreLocation
import Foundation
import Region
import Testing

@testable import RegionIntents

struct RegionEntityTests {
  let defaults: UserDefaults = UserDefaults(suiteName: "RegionEntityTests.\(UUID().uuidString)")!
  let minato = SavedRegion.place(
    name: "港区", coordinate: CLLocationCoordinate2D(latitude: 35.658, longitude: 139.751))

  var query: RegionEntityQuery {
    RegionEntityQuery(store: RegionStore(defaults: defaults))
  }

  @Test func suggestsTheSavedRegionsInTheirOrder() async throws {
    RegionStore(defaults: defaults).save([minato, .currentLocation])

    let ids = try await query.suggestedEntities().map(\.id)

    #expect(ids == [minato.id, SavedRegion.currentLocationID])
  }

  @Test func defaultsToTheFirstRegion() async {
    RegionStore(defaults: defaults).save([minato, .currentLocation])

    #expect(await query.defaultResult()?.id == minato.id)
  }

  @Test func hasNoDefaultBeforeARegionIsSaved() async {
    #expect(await query.defaultResult() == nil)
  }

  @Test func findsOnlyRegionsThatAreStillSaved() async throws {
    RegionStore(defaults: defaults).save([minato])

    let ids = try await query.entities(for: [minato.id, SavedRegion.currentLocationID]).map(\.id)

    #expect(ids == [minato.id])
  }

  @Test func namesThePlace() {
    #expect(RegionEntity(minato).placeName == "港区")
    #expect(RegionEntity(.currentLocation).placeName == nil)
  }

  @Test func translatesTheCurrentLocationFromItsOwnCatalog() {
    var title = RegionEntity(.currentLocation).displayRepresentation.title
    title.locale = Locale(identifier: "ja")

    #expect(String(localized: title) == "現在地")
  }
}
