import Observation
import SunnyDay
import WidgetKit

/// Which days the user counts as sunny.
@Observable
final class SunnyLevelSelection {
  private(set) var level: SunnyLevel

  @ObservationIgnored private let store: SunnyLevelStore

  init(store: SunnyLevelStore) {
    self.store = store
    level = store.load()
  }

  func select(_ level: SunnyLevel) {
    self.level = level
    store.save(level)
    WidgetCenter.shared.reloadAllTimelines()
  }
}
