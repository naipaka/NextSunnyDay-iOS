import Foundation
import Observation
import Units
import WidgetKit

/// Which unit the user wants temperatures in.
@Observable
final class TemperatureUnitSelection {
  private(set) var setting: TemperatureUnitSetting

  @ObservationIgnored private let store: TemperatureUnitStore

  init(store: TemperatureUnitStore) {
    self.store = store
    setting = store.load()
  }

  /// The unit to show temperatures in.
  var unit: UnitTemperature { setting.unit(for: .current) }

  func select(_ setting: TemperatureUnitSetting) {
    self.setting = setting
    store.save(setting)
    WidgetCenter.shared.reloadAllTimelines()
  }
}
