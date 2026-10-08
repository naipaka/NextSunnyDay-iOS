import AppGroup
public import Foundation

/// Keeps each region's forecast as `<region id>.json` in the App Group caches directory, shared by
/// the app and the widget. Every save replaces the file atomically, so the other process never
/// reads half a file.
///
/// The forecast can always be fetched again, so there are no migrations: a file written with
/// another `formatVersion`, or one that fails to decode, is deleted and treated as missing.
public actor ForecastCache {
  /// Bump when the meaning of the stored data changes without its shape changing.
  static let formatVersion = 2

  private struct File: Codable {
    var formatVersion: Int
    var forecast: CachedForecast
  }

  private let directory: URL

  /// The cache shared with the widget.
  public init() {
    self.init(directory: AppGroupContainer.cachesDirectory.appending(path: "forecasts"))
  }

  public init(directory: URL) {
    self.directory = directory
  }

  /// The region's forecast, or `nil` if there is none or it can't be read. It reads one small
  /// file synchronously, so that a screen can show the forecast in its first frame; saves replace
  /// the file atomically, so it never reads half a file.
  public nonisolated func load(regionID: String) -> CachedForecast? {
    let url = fileURL(regionID: regionID)
    guard let data = try? Data(contentsOf: url) else { return nil }
    guard let file = try? JSONDecoder().decode(File.self, from: data),
      file.formatVersion == Self.formatVersion
    else {
      try? FileManager.default.removeItem(at: url)
      return nil
    }
    return file.forecast
  }

  /// Replaces the region's forecast.
  public func save(_ forecast: CachedForecast) throws {
    let data = try JSONEncoder().encode(File(formatVersion: Self.formatVersion, forecast: forecast))
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try data.write(to: fileURL(regionID: forecast.regionID), options: .atomic)
  }

  /// Deletes the forecasts of regions that are not in `regionIDs`.
  public func removeAll(except regionIDs: Set<String>) {
    let keep = Set(regionIDs.map { fileURL(regionID: $0).lastPathComponent })
    let names =
      (try? FileManager.default.contentsOfDirectory(atPath: directory.path(percentEncoded: false)))
      ?? []
    for name in names where !keep.contains(name) {
      try? FileManager.default.removeItem(at: directory.appending(path: name))
    }
  }

  private nonisolated func fileURL(regionID: String) -> URL {
    directory.appending(path: "\(regionID).json", directoryHint: .notDirectory)
  }
}
