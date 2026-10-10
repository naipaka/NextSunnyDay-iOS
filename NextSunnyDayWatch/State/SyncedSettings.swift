import Foundation
import Observation
import Region
import SunnyDay
import Units

/// What the iPhone sends (the saved regions, the sunny level and the temperature unit), and the
/// region the watch shows, which the watch keeps for itself. Read again when new values arrive.
@Observable
final class SyncedSettings {
  private(set) var list: RegionList
  private(set) var level: SunnyLevel
  private(set) var unitSetting: TemperatureUnitSetting

  @ObservationIgnored private let features: WatchFeatures

  init(features: WatchFeatures) {
    self.features = features
    list = features.regionStore.loadList()
    level = features.sunnyLevelStore.load()
    unitSetting = features.temperatureUnitStore.load()
  }

  /// The region the watch shows: the one chosen on the watch, else the first.
  var region: SavedRegion? { list.selected }
  var regions: [SavedRegion] { list.regions }
  var unit: UnitTemperature { unitSetting.unit(for: .current) }

  /// Reads the stores again after the iPhone sent new values.
  func reload() {
    list = features.regionStore.loadList()
    level = features.sunnyLevelStore.load()
    unitSetting = features.temperatureUnitStore.load()
  }

  /// Chooses the region the watch shows.
  func select(_ region: SavedRegion) {
    var list = list
    list.select(region.id)
    guard list != self.list else { return }
    self.list = list
    features.regionStore.save(list)
  }
}
