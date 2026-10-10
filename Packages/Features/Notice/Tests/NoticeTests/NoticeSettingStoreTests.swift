import Foundation
import Notice
import Testing

struct NoticeSettingStoreTests {
  let defaults: UserDefaults = {
    let name = "NoticeSettingStoreTests.\(UUID().uuidString)"
    return UserDefaults(suiteName: name)!
  }()

  @Test func offAtSevenInTheEveningUntilSaved() {
    let setting = NoticeSettingStore(defaults: defaults).load()

    #expect(setting == .default)
    #expect(!setting.isOn)
    #expect(setting.regionID == nil)
    #expect(setting.time == NoticeTime(hour: 19, minute: 0))
  }

  @Test func keepsTheSavedSetting() {
    let setting = NoticeSetting(
      isOn: true, regionID: "region", time: NoticeTime(hour: 7, minute: 30))
    NoticeSettingStore(defaults: defaults).save(setting)

    #expect(NoticeSettingStore(defaults: defaults).load() == setting)
  }

  @Test func forgetsTheRegionForTheFirstOne() {
    let store = NoticeSettingStore(defaults: defaults)
    store.save(NoticeSetting(isOn: true, regionID: "region", time: .default))

    store.save(NoticeSetting(isOn: true, regionID: nil, time: .default))

    #expect(store.load().regionID == nil)
  }

  /// The stored format is never migrated, so it must not change.
  @Test func storesPlainValuesUnderFixedKeys() {
    NoticeSettingStore(defaults: defaults).save(
      NoticeSetting(isOn: true, regionID: "current-location", time: NoticeTime(hour: 7, minute: 30))
    )

    #expect(defaults.bool(forKey: "noticeOn"))
    #expect(defaults.string(forKey: "noticeRegion") == "current-location")
    #expect(defaults.integer(forKey: "noticeTime") == 450)
  }
}
