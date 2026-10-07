//
//  ForecastCache.swift
//  NextSunnyDay
//

import Foundation

// MARK: - ForecastCaching
/// Keeps the last fetched forecast of each region. Inject a fake through this protocol in tests
/// and previews.
protocol ForecastCaching: Sendable {
  /// The cached forecast, or `nil` if there is none or it can't be read.
  func load(for regionID: Region.ID) async -> ForecastSnapshot?
  /// Replaces the cached forecast of the region.
  func save(_ snapshot: ForecastSnapshot, for regionID: Region.ID) async throws
  /// Deletes the forecasts of regions that are not in `regionIDs`.
  func removeAll(except regionIDs: Set<Region.ID>) async
}

// MARK: - ForecastCache
/// Keeps each region's forecast as `<region id>.json` in the App Group caches directory, shared by
/// the app and the widget. Every save replaces the file atomically, so the other process never
/// reads half a file.
///
/// The forecast can always be fetched again, so there are no migrations: a file written with
/// another `formatVersion`, or one that fails to decode, is deleted and treated as missing.
actor ForecastCache: ForecastCaching {
  /// Bump when the meaning of the stored data changes without its shape changing.
  static let formatVersion = 1

  private struct File: Codable {
    var formatVersion: Int
    var snapshot: ForecastSnapshot
  }

  private let directory: URL

  init(directory: URL = AppGroup.cachesDirectory.appending(path: "forecasts")) {
    self.directory = directory
  }

  func load(for regionID: Region.ID) -> ForecastSnapshot? {
    let url = fileURL(for: regionID)
    guard let data = try? Data(contentsOf: url) else { return nil }
    guard let file = try? JSONDecoder().decode(File.self, from: data),
      file.formatVersion == Self.formatVersion
    else {
      try? FileManager.default.removeItem(at: url)
      return nil
    }
    return file.snapshot
  }

  func save(_ snapshot: ForecastSnapshot, for regionID: Region.ID) throws {
    let data = try JSONEncoder().encode(File(formatVersion: Self.formatVersion, snapshot: snapshot))
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try data.write(to: fileURL(for: regionID), options: .atomic)
  }

  func removeAll(except regionIDs: Set<Region.ID>) {
    let keep = Set(regionIDs.map { fileURL(for: $0).lastPathComponent })
    let names =
      (try? FileManager.default.contentsOfDirectory(atPath: directory.path(percentEncoded: false)))
      ?? []
    for name in names where !keep.contains(name) {
      try? FileManager.default.removeItem(at: directory.appending(path: name))
    }
  }

  private func fileURL(for regionID: Region.ID) -> URL {
    directory.appending(path: "\(regionID).json", directoryHint: .notDirectory)
  }
}
