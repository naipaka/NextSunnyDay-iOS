//
//  SettingsStoreTests.swift
//  NextSunnyDayTests
//

import Foundation
import Testing

@testable import NextSunnyDay

final class SettingsStoreTests {
  private let suiteName = "SettingsStoreTests-\(UUID().uuidString)"
  private let defaults: UserDefaults
  private let store: SettingsStore
  private let tokyo = ForecastLocation(name: "東京駅", latitude: 35.681, longitude: 139.767)

  init() {
    defaults = UserDefaults(suiteName: suiteName)!
    store = SettingsStore(defaults: defaults)
  }

  deinit {
    defaults.removePersistentDomain(forName: suiteName)
  }

  @Test func defaultsWithoutStoredValues() {
    #expect(store.regions.isEmpty)
    #expect(store.sunnyLevel == .mostlyClear)
  }

  @Test func regionsRoundTrip() {
    let regions = [Region.place(tokyo), .currentLocation]
    store.regions = regions
    #expect(SettingsStore(defaults: defaults).regions == regions)
  }

  @Test func placesGetDistinctIDsAndTheCurrentLocationAFixedOne() {
    #expect(Region.place(tokyo).id != Region.place(tokyo).id)
    #expect(Region.currentLocation.id == "current-location")
  }

  @Test func settingNoRegionsRemovesTheKey() {
    store.regions = [.place(tokyo)]
    store.regions = []
    #expect(store.regions.isEmpty)
    #expect(defaults.object(forKey: "regions") == nil)
  }

  @Test(arguments: SunnyLevel.allCases)
  func sunnyLevelRoundTrips(_ level: SunnyLevel) {
    store.sunnyLevel = level
    #expect(SettingsStore(defaults: defaults).sunnyLevel == level)
  }

  @Test func unknownStoredValuesFallBackToDefaults() {
    defaults.set("sometimes", forKey: "sunnyLevel")
    defaults.set(Data("{}".utf8), forKey: "regions")
    #expect(store.sunnyLevel == .mostlyClear)
    #expect(store.regions.isEmpty)
  }

  // `HomeViewModel` relies on this to notice a region picked on the settings screen.
  @Test func savingRegionsPostsDidChangeNotification() async {
    await confirmation { changed in
      let observer = NotificationCenter.default.addObserver(
        forName: UserDefaults.didChangeNotification, object: defaults, queue: nil
      ) { _ in changed() }
      store.regions = [.place(tokyo)]
      NotificationCenter.default.removeObserver(observer)
    }
  }

  // MARK: Stored format
  // Settings are never migrated, so every later version must read what earlier ones wrote.
  // If one of these tests fails, keep the old format readable instead of updating the test.

  private static let storedRegions = """
    [{"id":"current-location","kind":{"currentLocation":{}}},\
    {"id":"6F1C7E1A-3D5B-4C2A-9E0F-1B2C3D4E5F60","kind":{"place":{"location":\
    {"latitude":35.681,"longitude":139.767,"name":"東京駅"}}}}]
    """

  @Test func readsTheStoredRegionsFormat() {
    defaults.set(Data(Self.storedRegions.utf8), forKey: "regions")
    #expect(
      store.regions == [
        .currentLocation,
        Region(id: "6F1C7E1A-3D5B-4C2A-9E0F-1B2C3D4E5F60", kind: .place(tokyo)),
      ])
  }

  @Test func writesTheStoredRegionsFormat() throws {
    let regions = try JSONDecoder().decode([Region].self, from: Data(Self.storedRegions.utf8))
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    #expect(String(decoding: try encoder.encode(regions), as: UTF8.self) == Self.storedRegions)
  }

  @Test func sunnyLevelRawValuesAreStable() {
    #expect(
      SunnyLevel.allCases.map(\.rawValue) == ["clear", "mostlyClear", "partlyCloudy", "noRain"])
  }
}
