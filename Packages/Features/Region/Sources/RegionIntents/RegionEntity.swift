public import AppIntents
import Foundation
public import Region

/// Lets the app's and the widget's App Intents use the types defined here. Each target that uses
/// them declares its own `AppIntentsPackage` that includes this one.
public struct RegionIntentsPackage: AppIntentsPackage {}

/// A saved region, as Siri, Shortcuts and the widget's configuration list it.
///
/// The type name is written into the App Intents metadata as a key only, so the system looks it up
/// in the host's String Catalog; each host has the key too. The display representation is made
/// at run time and comes from this module's catalog.
public struct RegionEntity: AppEntity {
  public static let typeDisplayRepresentation = TypeDisplayRepresentation(
    name: LocalizedStringResource("Region", bundle: #bundle))
  public static let defaultQuery = RegionEntityQuery()

  public let id: String
  /// `nil` for the current location.
  public let placeName: String?

  public init(_ region: SavedRegion) {
    id = region.id
    placeName = region.placeName
  }

  public var displayRepresentation: DisplayRepresentation {
    if let placeName {
      DisplayRepresentation(title: "\(placeName)")
    } else {
      DisplayRepresentation(title: LocalizedStringResource("Current Location", bundle: #bundle))
    }
  }
}

/// The regions saved in the app, in their order.
public struct RegionEntityQuery: EntityQuery {
  private let store: RegionStore

  public init() {
    self.init(store: RegionStore())
  }

  init(store: RegionStore) {
    self.store = store
  }

  public func entities(for identifiers: [String]) async throws -> [RegionEntity] {
    store.load().filter { identifiers.contains($0.id) }.map(RegionEntity.init)
  }

  public func suggestedEntities() async throws -> [RegionEntity] {
    store.load().map(RegionEntity.init)
  }

  public func defaultResult() async -> RegionEntity? {
    store.load().first.map(RegionEntity.init)
  }
}
