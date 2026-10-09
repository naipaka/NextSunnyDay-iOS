import AppIntents
import Region

/// The widget's configuration: which saved region it shows. Left empty, or when the region is
/// removed, the widget shows the first region in the app's list.
struct SelectRegionIntent: WidgetConfigurationIntent {
  static let title: LocalizedStringResource = "Region"

  @Parameter(title: "Region")
  var region: RegionEntity?
}

/// A saved region, as the widget's configuration lists it.
struct RegionEntity: AppEntity {
  static let typeDisplayRepresentation: TypeDisplayRepresentation = "Region"
  static let defaultQuery = RegionEntityQuery()

  let id: String
  /// `nil` for the current location.
  let placeName: String?

  init(_ region: SavedRegion) {
    id = region.id
    placeName = region.placeName
  }

  var displayRepresentation: DisplayRepresentation {
    if let placeName {
      DisplayRepresentation(title: "\(placeName)")
    } else {
      DisplayRepresentation(title: "Current Location")
    }
  }
}

/// The regions saved in the app, in their order.
struct RegionEntityQuery: EntityQuery {
  func entities(for identifiers: [String]) async throws -> [RegionEntity] {
    RegionStore().load().filter { identifiers.contains($0.id) }.map(RegionEntity.init)
  }

  func suggestedEntities() async throws -> [RegionEntity] {
    RegionStore().load().map(RegionEntity.init)
  }

  func defaultResult() async -> RegionEntity? {
    RegionStore().load().first.map(RegionEntity.init)
  }
}
