public import Foundation

/// The user's regions in their order, and which one is chosen.
public struct RegionList: Equatable, Sendable {
  /// How many regions can be saved; the current location counts as one.
  public static let maximumCount = 3

  public private(set) var regions: [SavedRegion]
  /// The ID of the chosen region, as saved; `selected` falls back to the first region.
  public private(set) var selectedID: String?

  public init(regions: [SavedRegion] = [], selectedID: String? = nil) {
    self.regions = regions
    self.selectedID = selectedID
  }

  /// The chosen region, or the first one when the chosen one is gone. `nil` without regions.
  public var selected: SavedRegion? {
    regions.first { $0.id == selectedID } ?? regions.first
  }

  /// The saved region with this ID, or the first one when there is no such region: what a widget
  /// shows before its region is picked, or after the picked region was removed.
  public func region(id: String?) -> SavedRegion? {
    regions.first { $0.id == id } ?? regions.first
  }

  public var isFull: Bool {
    regions.count >= Self.maximumCount
  }

  public var containsCurrentLocation: Bool {
    regions.contains { $0.kind == .currentLocation }
  }

  /// Adds `region` at the end and chooses it. A region that is already saved (the current
  /// location, or the same place) is chosen instead of added again. Returns `false` when the list
  /// is full and nothing changed.
  @discardableResult
  public mutating func add(_ region: SavedRegion) -> Bool {
    if let saved = regions.first(where: { $0.kind == region.kind }) {
      selectedID = saved.id
      return true
    }
    guard !isFull else { return false }
    regions.append(region)
    selectedID = region.id
    return true
  }

  /// Chooses the saved region with this ID.
  public mutating func select(_ id: String) {
    guard regions.contains(where: { $0.id == id }) else { return }
    selectedID = id
  }

  /// Whether a region can be removed: the last one can't, since the app needs one.
  public var canRemove: Bool {
    regions.count > 1
  }

  /// Removes the regions at `offsets`, keeping at least one. When the chosen region is removed,
  /// the first remaining one is chosen.
  public mutating func remove(atOffsets offsets: IndexSet) {
    let remaining = regions.indices.filter { !offsets.contains($0) }.map { regions[$0] }
    guard !remaining.isEmpty else { return }
    let selected = selected
    regions = remaining
    selectedID = (selected.flatMap { regions.contains($0) ? $0 : nil } ?? regions.first)?.id
  }

  /// Moves the regions at `offsets` before the region at `destination`, as `List` reports moves.
  public mutating func move(fromOffsets offsets: IndexSet, toOffset destination: Int) {
    let moving = offsets.filter { regions.indices.contains($0) }.map { regions[$0] }
    var rest = regions.indices.filter { !offsets.contains($0) }.map { regions[$0] }
    let insertion = destination - offsets.count { $0 < destination }
    rest.insert(contentsOf: moving, at: min(max(insertion, 0), rest.count))
    regions = rest
  }
}
