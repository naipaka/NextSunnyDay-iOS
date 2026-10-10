import Foundation
import Testing
import WatchSync

struct SettingsMirrorTests {
  let phone = makeDefaults()
  let watch = makeDefaults()

  private static func makeDefaults() -> UserDefaults {
    UserDefaults(suiteName: "SettingsMirrorTests.\(UUID().uuidString)")!
  }

  private func mirror(_ defaults: UserDefaults) -> SettingsMirror {
    SettingsMirror(keys: ["regions", "sunnyLevel"], defaults: defaults)
  }

  @Test func copiesTheValuesOfItsKeys() {
    phone.set(Data([1, 2, 3]), forKey: "regions")
    phone.set("clearOnly", forKey: "sunnyLevel")

    mirror(watch).apply(mirror(phone).context())

    #expect(watch.data(forKey: "regions") == Data([1, 2, 3]))
    #expect(watch.string(forKey: "sunnyLevel") == "clearOnly")
  }

  @Test func leavesOtherKeysAlone() {
    phone.set("selected-on-the-phone", forKey: "selectedRegion")
    watch.set("selected-on-the-watch", forKey: "selectedRegion")

    let context = mirror(phone).context()
    mirror(watch).apply(context.merging(["selectedRegion": "sent"]) { $1 })

    #expect(context["selectedRegion"] == nil)
    #expect(watch.string(forKey: "selectedRegion") == "selected-on-the-watch")
  }

  @Test func removesKeysTheContextDoesNotHave() {
    watch.set("clearOnly", forKey: "sunnyLevel")
    phone.set(Data([1]), forKey: "regions")

    mirror(watch).apply(mirror(phone).context())

    #expect(watch.object(forKey: "sunnyLevel") == nil)
  }

  @Test func saysWhetherSomethingChanged() {
    phone.set("clearOnly", forKey: "sunnyLevel")
    let context = mirror(phone).context()

    #expect(mirror(watch).apply(context))
    #expect(!mirror(watch).apply(context))
  }
}
