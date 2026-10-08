import Testing

@testable import Location

struct WithTimeoutTests {
  @Test func returnsTheResultWhenItComesInTime() async throws {
    #expect(try await withTimeout(.seconds(5)) { 1 } == 1)
  }

  @Test func returnsNilWhenTheTimeoutPassesFirst() async throws {
    let result = try await withTimeout(.milliseconds(50)) { () async throws -> Int? in
      try await Task.sleep(for: .seconds(5))
      return 1
    }

    #expect(result == nil)
  }

  @Test func passesErrorsThrough() async {
    await #expect(throws: LocationError.denied) {
      try await withTimeout(.seconds(5)) { () async throws -> Int? in throw LocationError.denied }
    }
  }
}
