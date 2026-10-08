import AppGroup
public import Foundation

/// Keeps the user's regions in App Group `UserDefaults`, so the widget reads the same ones.
///
/// Never migrated: the stored format must stay readable by every later version
/// (`RegionStoreTests` pins it). Regions are a list from the start, although the app keeps only
/// one for now.
///
/// `@unchecked` because `UserDefaults` is not marked `Sendable`, although it is thread-safe.
public struct RegionStore: @unchecked Sendable {
  static let key = "regions"

  private let defaults: UserDefaults

  /// The store shared with the widget.
  public init() {
    self.init(defaults: AppGroupContainer.userDefaults)
  }

  public init(defaults: UserDefaults) {
    self.defaults = defaults
  }

  /// Empty until the user picks a region.
  public func load() -> [SavedRegion] {
    defaults.data(forKey: Self.key)
      .flatMap { try? JSONDecoder().decode([SavedRegion].self, from: $0) } ?? []
  }

  public func save(_ regions: [SavedRegion]) {
    if !regions.isEmpty, let data = try? JSONEncoder().encode(regions) {
      defaults.set(data, forKey: Self.key)
    } else {
      defaults.removeObject(forKey: Self.key)
    }
  }
}
