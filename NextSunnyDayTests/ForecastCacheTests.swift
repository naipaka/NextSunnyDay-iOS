//
//  ForecastCacheTests.swift
//  NextSunnyDayTests
//

import Foundation
import Testing

@testable import NextSunnyDay

final class ForecastCacheTests {
  private let directory = FileManager.default.temporaryDirectory
    .appending(path: "ForecastCacheTests-\(UUID().uuidString)", directoryHint: .isDirectory)
  private let snapshot = ForecastSnapshot.sample(now: Date(timeIntervalSince1970: 1_800_000_000))
  private let regionID = "6F1C7E1A-3D5B-4C2A-9E0F-1B2C3D4E5F60"

  deinit {
    try? FileManager.default.removeItem(at: directory)
  }

  private func fileExists(_ regionID: Region.ID) -> Bool {
    FileManager.default.fileExists(
      atPath: directory.appending(path: "\(regionID).json").path(percentEncoded: false))
  }

  private func write(_ data: Data, for regionID: Region.ID) throws {
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try data.write(to: directory.appending(path: "\(regionID).json"))
  }

  @Test func loadReturnsNilWithoutFile() async {
    #expect(await ForecastCache(directory: directory).load(for: regionID) == nil)
  }

  @Test func savedSnapshotLoadsBackUnchanged() async throws {
    try await ForecastCache(directory: directory).save(snapshot, for: regionID)
    // A new instance, like the widget process, reads the same file.
    #expect(await ForecastCache(directory: directory).load(for: regionID) == snapshot)
  }

  @Test func saveReplacesTheSnapshot() async throws {
    let cache = ForecastCache(directory: directory)
    try await cache.save(snapshot, for: regionID)
    var newer = snapshot
    newer.fetchedAt = snapshot.fetchedAt.addingTimeInterval(60)
    try await cache.save(newer, for: regionID)
    #expect(await cache.load(for: regionID) == newer)
  }

  @Test func regionsHaveSeparateSnapshots() async throws {
    let cache = ForecastCache(directory: directory)
    var osaka = snapshot
    osaka.location = ForecastLocation(name: "大阪駅", latitude: 34.702, longitude: 135.496)
    try await cache.save(snapshot, for: regionID)
    try await cache.save(osaka, for: Region.currentLocationID)
    #expect(await cache.load(for: regionID) == snapshot)
    #expect(await cache.load(for: Region.currentLocationID) == osaka)
  }

  @Test func removeAllKeepsOnlyTheGivenRegions() async throws {
    let cache = ForecastCache(directory: directory)
    try await cache.save(snapshot, for: regionID)
    try await cache.save(snapshot, for: Region.currentLocationID)
    try await cache.save(snapshot, for: "removed-region")
    await cache.removeAll(except: [regionID, Region.currentLocationID])
    #expect(fileExists(regionID))
    #expect(fileExists(Region.currentLocationID))
    #expect(!fileExists("removed-region"))
  }

  @Test func removeAllToleratesAMissingDirectory() async {
    await ForecastCache(directory: directory).removeAll(except: [])
  }

  @Test func unreadableFileIsDiscarded() async throws {
    try write(Data("not json".utf8), for: regionID)
    #expect(await ForecastCache(directory: directory).load(for: regionID) == nil)
    #expect(!fileExists(regionID))
  }

  @Test func fileWithAnotherFormatVersionIsDiscarded() async throws {
    let snapshotObject = try JSONSerialization.jsonObject(with: JSONEncoder().encode(snapshot))
    let file: [String: Any] = [
      "formatVersion": ForecastCache.formatVersion + 1, "snapshot": snapshotObject,
    ]
    try write(JSONSerialization.data(withJSONObject: file), for: regionID)
    #expect(await ForecastCache(directory: directory).load(for: regionID) == nil)
    #expect(!fileExists(regionID))
  }
}
