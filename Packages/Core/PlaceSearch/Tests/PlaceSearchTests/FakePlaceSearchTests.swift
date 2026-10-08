import CoreLocation
import PlaceSearch
import PlaceSearchTesting
import Testing

struct FakePlaceSearchTests {
  let search = FakePlaceSearch()

  @Test func completionsMatchByPrefix() async throws {
    let titles = try await search.completions(for: "港").map(\.subtitle)

    #expect(titles == ["東京都", "大阪府大阪市"])
  }

  @Test func aCompletionLeadsToItsPlace() async throws {
    let completion = PlaceCompletion(title: "札幌市", subtitle: "北海道")

    let place = try await search.place(for: completion)

    #expect(place.name == "札幌市")
    #expect(place.coordinate.latitude == 43.062)
  }

  @Test func anUnknownCompletionIsNotFound() async {
    await #expect(throws: PlaceSearchError.notFound) {
      try await search.place(for: PlaceCompletion(title: "どこでもない", subtitle: ""))
    }
  }
}
