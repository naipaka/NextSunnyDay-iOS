import PlaceSearch
import PlaceSearchTesting
import Region
import Testing

struct RegionSearchTests {
  let search = RegionSearch(places: FakePlaceSearch())

  @Test func findsCandidatesByName() async throws {
    let candidates = try await search.candidates(for: "港区")

    #expect(candidates.map(\.name) == ["港区", "港区"])
    #expect(candidates.map(\.area) == ["東京都", "大阪府大阪市"])
  }

  @Test func ignoresSurroundingSpaces() async throws {
    #expect(try await search.candidates(for: "  札幌 ").map(\.name) == ["札幌市"])
  }

  @Test func aBlankQueryFindsNothing() async throws {
    #expect(try await search.candidates(for: "   ").isEmpty)
  }

  @Test func thePickedCandidateBecomesAPlaceWithANewID() async throws {
    let candidate = try #require(try await search.candidates(for: "札幌").first)

    let first = try await search.region(for: candidate)
    let second = try await search.region(for: candidate)

    #expect(first.kind == .place(name: "札幌市", latitude: 43.062, longitude: 141.354))
    #expect(first.id != second.id)
    #expect(first.id != SavedRegion.currentLocationID)
  }
}
