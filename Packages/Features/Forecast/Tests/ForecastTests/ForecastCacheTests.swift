import CoreLocation
import Forecast
import Foundation
import Testing
import WeatherTesting

final class ForecastCacheTests {
  private let directory = FileManager.default.temporaryDirectory
    .appending(path: "ForecastCacheTests-\(UUID().uuidString)", directoryHint: .isDirectory)
  private let regionID = "6F1C7E1A-3D5B-4C2A-9E0F-1B2C3D4E5F60"

  deinit {
    try? FileManager.default.removeItem(at: directory)
  }

  private func forecast(regionID: String, placeName: String? = "港区") -> CachedForecast {
    CachedForecast(
      regionID: regionID, placeName: placeName,
      coordinate: CLLocationCoordinate2D(latitude: 35.658, longitude: 139.751),
      fetchedAt: Date(timeIntervalSince1970: 1_800_000_000),
      forecast: WeatherRecording.tokyo.recorded)
  }

  private func fileExists(_ regionID: String) -> Bool {
    FileManager.default.fileExists(
      atPath: directory.appending(path: "\(regionID).json").path(percentEncoded: false))
  }

  private func write(_ data: Data, for regionID: String) throws {
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try data.write(to: directory.appending(path: "\(regionID).json"))
  }

  @Test func loadReturnsNilWithoutFile() async {
    #expect(ForecastCache(directory: directory).load(regionID: regionID) == nil)
  }

  @Test func savedForecastLoadsBackUnchanged() async throws {
    let saved = forecast(regionID: regionID)
    try await ForecastCache(directory: directory).save(saved)

    // A new instance, like the widget process, reads the same file.
    #expect(ForecastCache(directory: directory).load(regionID: regionID) == saved)
  }

  @Test func saveReplacesTheForecast() async throws {
    let cache = ForecastCache(directory: directory)
    try await cache.save(forecast(regionID: regionID))
    var newer = forecast(regionID: regionID)
    newer.fetchedAt += 60
    try await cache.save(newer)

    #expect(cache.load(regionID: regionID) == newer)
  }

  @Test func regionsHaveSeparateForecasts() async throws {
    let cache = ForecastCache(directory: directory)
    try await cache.save(forecast(regionID: regionID, placeName: "港区"))
    try await cache.save(forecast(regionID: "current-location", placeName: "大阪市"))

    #expect(cache.load(regionID: regionID)?.placeName == "港区")
    #expect(cache.load(regionID: "current-location")?.placeName == "大阪市")
  }

  @Test func removeAllKeepsOnlyTheGivenRegions() async throws {
    let cache = ForecastCache(directory: directory)
    for id in [regionID, "current-location", "removed-region"] {
      try await cache.save(forecast(regionID: id))
    }
    await cache.removeAll(except: [regionID, "current-location"])

    #expect(fileExists(regionID))
    #expect(fileExists("current-location"))
    #expect(!fileExists("removed-region"))
  }

  @Test func removeAllToleratesAMissingDirectory() async {
    await ForecastCache(directory: directory).removeAll(except: [])
  }

  @Test func unreadableFileIsDiscarded() async throws {
    try write(Data("not json".utf8), for: regionID)

    #expect(ForecastCache(directory: directory).load(regionID: regionID) == nil)
    #expect(!fileExists(regionID))
  }

  @Test func fileOfAnotherFormatVersionIsDiscarded() async throws {
    let cache = ForecastCache(directory: directory)
    try await cache.save(forecast(regionID: regionID))
    let url = directory.appending(path: "\(regionID).json")
    var json = try #require(
      try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
    json["formatVersion"] = 1
    try JSONSerialization.data(withJSONObject: json).write(to: url)

    #expect(cache.load(regionID: regionID) == nil)
    #expect(!fileExists(regionID))
  }
}
