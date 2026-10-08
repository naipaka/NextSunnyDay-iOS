import Foundation
import Testing
import Units

struct TemperatureUnitSettingTests {
  @Test func systemFollowsTheRegion() {
    #expect(TemperatureUnitSetting.system.unit(for: Locale(identifier: "en_US")) == .fahrenheit)
    #expect(TemperatureUnitSetting.system.unit(for: Locale(identifier: "ja_JP")) == .celsius)
  }

  @Test func systemFollowsTheTemperaturePreference() {
    let locale = Locale(identifier: "ja_JP@mu=fahrenhe")

    #expect(TemperatureUnitSetting.system.unit(for: locale) == .fahrenheit)
  }

  @Test func aChosenUnitIgnoresTheRegion() {
    #expect(TemperatureUnitSetting.celsius.unit(for: Locale(identifier: "en_US")) == .celsius)
    #expect(TemperatureUnitSetting.fahrenheit.unit(for: Locale(identifier: "ja_JP")) == .fahrenheit)
  }
}
