import Foundation
import Testing
import Units

struct TemperatureUnitStoreTests {
  let defaults: UserDefaults = {
    let name = "TemperatureUnitStoreTests.\(UUID().uuidString)"
    return UserDefaults(suiteName: name)!
  }()

  @Test func followsTheSystemUntilSaved() {
    #expect(TemperatureUnitStore(defaults: defaults).load() == .system)
  }

  @Test func keepsTheSavedSetting() {
    TemperatureUnitStore(defaults: defaults).save(.fahrenheit)

    #expect(TemperatureUnitStore(defaults: defaults).load() == .fahrenheit)
  }

  /// The stored format is never migrated, so it must not change.
  @Test func storesTheRawValueUnderAFixedKey() {
    TemperatureUnitStore(defaults: defaults).save(.celsius)

    #expect(defaults.string(forKey: "temperatureUnit") == "celsius")
  }
}
