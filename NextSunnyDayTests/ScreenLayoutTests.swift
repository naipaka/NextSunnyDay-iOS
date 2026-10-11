import SwiftUI
import Testing

@testable import NextSunnyDay

struct ScreenLayoutTests {
  @Test func iPhoneInPortraitIsCompact() {
    #expect(
      ScreenLayout(width: 402, horizontalSizeClass: .compact, verticalSizeClass: .regular)
        == .compact)
  }

  @Test func everyIPhoneInLandscapeGetsThePanel() {
    // The iPhone 17 is compact both ways in landscape; the Pro Max is regular wide.
    #expect(
      ScreenLayout(width: 874, horizontalSizeClass: .compact, verticalSizeClass: .compact) == .panel
    )
    #expect(
      ScreenLayout(width: 956, horizontalSizeClass: .regular, verticalSizeClass: .compact) == .panel
    )
  }

  @Test(arguments: [
    // iPad Pro 11" and 13" and iPad mini in landscape
    (1210.0, ScreenLayout.panel), (1376, .panel), (1133, .panel),
    // the same in portrait
    (834, .stacked), (1032, .stacked), (744, .stacked),
  ])
  func iPadFollowsTheWidth(width: Double, layout: ScreenLayout) {
    #expect(
      ScreenLayout(width: width, horizontalSizeClass: .regular, verticalSizeClass: .regular)
        == layout)
  }

  @Test func aNarrowIPadWindowIsCompact() {
    #expect(
      ScreenLayout(width: 500, horizontalSizeClass: .compact, verticalSizeClass: .regular)
        == .compact)
  }
}
