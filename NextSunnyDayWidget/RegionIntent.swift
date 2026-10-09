import AppIntents
import RegionIntents

/// Includes `RegionEntity`, which the configuration below uses, from the `RegionIntents` module.
struct WidgetIntentsPackage: AppIntentsPackage {
  static var includedPackages: [any AppIntentsPackage.Type] { [RegionIntentsPackage.self] }
}

/// The widget's configuration: which saved region it shows. Left empty, or when the region is
/// removed, the widget shows the first region in the app's list.
struct SelectRegionIntent: WidgetConfigurationIntent {
  static let title: LocalizedStringResource = "Region"

  @Parameter(title: "Region")
  var region: RegionEntity?
}
