import CoreLocation
import Foundation
import Region
import Testing

struct RegionListTests {
  private let minato = SavedRegion.place(
    name: "港区", coordinate: CLLocationCoordinate2D(latitude: 35.658, longitude: 139.751))
  private let sapporo = SavedRegion.place(
    name: "札幌市", coordinate: CLLocationCoordinate2D(latitude: 43.062, longitude: 141.354))
  private let naha = SavedRegion.place(
    name: "那覇市", coordinate: CLLocationCoordinate2D(latitude: 26.212, longitude: 127.681))

  @Test func isEmptyAtFirst() {
    let list = RegionList()
    #expect(list.selected == nil)
    #expect(!list.isFull)
  }

  @Test func anAddedRegionIsChosen() {
    var list = RegionList()
    list.add(minato)
    list.add(sapporo)

    #expect(list.regions == [minato, sapporo])
    #expect(list.selected == sapporo)
  }

  @Test func holdsUpToThreeRegions() {
    var list = RegionList()
    list.add(minato)
    list.add(.currentLocation)
    list.add(sapporo)

    #expect(list.isFull)
    let added = list.add(naha)
    #expect(!added)
    #expect(list.regions == [minato, .currentLocation, sapporo])
    #expect(list.selected == sapporo)
  }

  @Test func aSavedRegionIsChosenInsteadOfAddedAgain() {
    var list = RegionList()
    list.add(.currentLocation)
    list.add(minato)
    list.add(sapporo)

    // Search gives the same place a new ID each time.
    let added = list.add(
      .place(name: "港区", coordinate: CLLocationCoordinate2D(latitude: 35.658, longitude: 139.751)))
    #expect(added)
    #expect(list.selected == minato)
    list.add(.currentLocation)
    #expect(list.selected == .currentLocation)
    #expect(list.regions.count == 3)
  }

  @Test func choosesASavedRegion() {
    var list = RegionList(regions: [minato, sapporo])
    #expect(list.selected == minato)

    list.select(sapporo.id)
    #expect(list.selected == sapporo)

    list.select("unknown")
    #expect(list.selected == sapporo)
  }

  @Test func removingTheChosenRegionChoosesTheFirst() {
    var list = RegionList(regions: [minato, sapporo, naha], selectedID: sapporo.id)

    list.remove(atOffsets: [1])

    #expect(list.regions == [minato, naha])
    #expect(list.selected == minato)
    #expect(list.selectedID == minato.id)
  }

  @Test func removingAnotherRegionKeepsTheChoice() {
    var list = RegionList(regions: [minato, sapporo, naha], selectedID: naha.id)

    list.remove(atOffsets: [0])

    #expect(list.selected == naha)
  }

  @Test func theLastRegionStays() {
    var list = RegionList(regions: [minato])
    #expect(!list.canRemove)

    list.remove(atOffsets: [0])

    #expect(list.regions == [minato])
  }

  @Test func movesAsListReportsIt() {
    var list = RegionList(regions: [minato, sapporo, naha], selectedID: sapporo.id)

    // Dragging the first row below the last one.
    list.move(fromOffsets: [0], toOffset: 3)
    #expect(list.regions == [sapporo, naha, minato])

    // Dragging the last row to the top.
    list.move(fromOffsets: [2], toOffset: 0)
    #expect(list.regions == [minato, sapporo, naha])
    #expect(list.selected == sapporo)
  }

  @Test func aMissingChoiceFallsBackToTheFirst() {
    let list = RegionList(regions: [minato, sapporo], selectedID: "removed")
    #expect(list.selected == minato)
  }
}
