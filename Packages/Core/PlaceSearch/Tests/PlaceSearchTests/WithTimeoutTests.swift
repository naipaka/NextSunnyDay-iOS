import Testing

@testable import PlaceSearch

struct WithTimeoutTests {
  @Test func returnsTheResultWhenItComesInTime() async throws {
    #expect(try await withTimeout(.seconds(5)) { "港区" } == "港区")
  }

  @Test func returnsNilWhenTheTimeoutPassesFirst() async throws {
    let result = try await withTimeout(.milliseconds(50)) { () async throws -> String? in
      try await Task.sleep(for: .seconds(5))
      return "港区"
    }

    #expect(result == nil)
  }

  @Test func passesErrorsThrough() async {
    await #expect(throws: PlaceSearchError.notFound) {
      try await withTimeout(.seconds(5)) { () async throws -> String? in
        throw PlaceSearchError.notFound
      }
    }
  }
}
