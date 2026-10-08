import CoreLocation
import Foundation
import Region
import Testing

struct RegionStoreTests {
  let defaults: UserDefaults = UserDefaults(suiteName: "RegionStoreTests.\(UUID().uuidString)")!

  @Test func isEmptyUntilSaved() {
    #expect(RegionStore(defaults: defaults).load().isEmpty)
  }

  @Test func keepsTheSavedRegions() {
    let regions = [
      SavedRegion.currentLocation,
      .place(name: "港区", coordinate: CLLocationCoordinate2D(latitude: 35.658, longitude: 139.751)),
    ]
    RegionStore(defaults: defaults).save(regions)

    #expect(RegionStore(defaults: defaults).load() == regions)
  }

  @Test func savingNoRegionsRemovesTheKey() {
    let store = RegionStore(defaults: defaults)
    store.save([.currentLocation])
    store.save([])

    #expect(defaults.object(forKey: "regions") == nil)
  }

  /// The stored format is never migrated, so data written by this version must stay readable.
  @Test func readsTheStoredFormat() throws {
    let json = """
      [
        {"id": "current-location", "kind": {"currentLocation": {}}},
        {"id": "6F1C7E1A-3D5B-4C2A-9E0F-1B2C3D4E5F60",
         "kind": {"place": {"name": "港区", "latitude": 35.658, "longitude": 139.751}}}
      ]
      """
    defaults.set(Data(json.utf8), forKey: "regions")

    #expect(
      RegionStore(defaults: defaults).load() == [
        .currentLocation,
        SavedRegion(
          id: "6F1C7E1A-3D5B-4C2A-9E0F-1B2C3D4E5F60",
          kind: .place(name: "港区", latitude: 35.658, longitude: 139.751)),
      ])
  }
}
