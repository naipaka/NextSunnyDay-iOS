import Foundation
import SunnyDay
import Testing

struct SunnyLevelStoreTests {
  let defaults: UserDefaults = {
    let name = "SunnyLevelStoreTests.\(UUID().uuidString)"
    return UserDefaults(suiteName: name)!
  }()

  @Test func isTheDefaultUntilSaved() {
    #expect(SunnyLevelStore(defaults: defaults).load() == .default)
  }

  @Test func keepsTheSavedLevel() {
    SunnyLevelStore(defaults: defaults).save(.noRain)

    #expect(SunnyLevelStore(defaults: defaults).load() == .noRain)
  }

  /// The stored format is never migrated, so it must not change.
  @Test func storesTheRawValueUnderAFixedKey() {
    SunnyLevelStore(defaults: defaults).save(.partlyCloudy)

    #expect(defaults.string(forKey: "sunnyLevel") == "partlyCloudy")
  }
}
