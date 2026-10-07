//
//  ForecastSnapshotTests.swift
//  NextSunnyDayTests
//

import Foundation
import Testing

@testable import NextSunnyDay

struct ForecastSnapshotTests {
  private let now = Date(timeIntervalSince1970: 1_800_000_000)
  private let hour: TimeInterval = 60 * 60
  private let tokyo = ForecastLocation(name: "東京駅", latitude: 35.681, longitude: 139.767)
  private let osaka = ForecastLocation(name: "大阪駅", latitude: 34.702, longitude: 135.496)

  private func snapshot(firstDay: Date, location: ForecastLocation? = nil) -> ForecastSnapshot {
    ForecastSnapshot(
      location: location ?? tokyo, fetchedAt: firstDay,
      daily: [
        .sample(date: firstDay.addingTimeInterval(24 * hour), condition: .clear),
        .sample(date: firstDay, condition: .rain),
      ],
      hourly: [])
  }

  @Test func freshSnapshotDoesNotNeedRefresh() {
    let snapshot = snapshot(firstDay: now.addingTimeInterval(-23 * hour))
    #expect(!snapshot.needsRefresh(for: tokyo, now: now, maxAge: 24 * hour))
  }

  @Test func snapshotWhoseFirstDayIsTooOldNeedsRefresh() {
    let snapshot = snapshot(firstDay: now.addingTimeInterval(-25 * hour))
    #expect(snapshot.needsRefresh(for: tokyo, now: now, maxAge: 24 * hour))
  }

  @Test func snapshotForAnotherLocationNeedsRefresh() {
    #expect(snapshot(firstDay: now).needsRefresh(for: osaka, now: now, maxAge: 24 * hour))
  }

  @Test func snapshotWithoutDaysNeedsRefresh() {
    let snapshot = ForecastSnapshot(location: tokyo, fetchedAt: now, daily: [], hourly: [])
    #expect(snapshot.needsRefresh(for: tokyo, now: now, maxAge: 24 * hour))
  }

  @Test func placeMatchesOnlyItsOwnSnapshot() {
    #expect(Region.place(tokyo).matches(snapshot(firstDay: now)))
    #expect(!Region.place(osaka).matches(snapshot(firstDay: now)))
  }

  @Test func currentLocationMatchesAnySnapshot() {
    #expect(Region.currentLocation.matches(snapshot(firstDay: now, location: osaka)))
  }
}
