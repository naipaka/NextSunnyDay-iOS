import SwiftUI
import Testing

@testable import NextSunnyDay

struct ScreenLayoutTests {
  @Test func iPhoneInPortraitIsCompact() {
    #expect(
      ScreenLayout(
        size: CGSize(width: 402, height: 874), horizontalSizeClass: .compact,
        verticalSizeClass: .regular) == .compact)
  }

  @Test func everyIPhoneInLandscapeGetsThePanel() {
    // The iPhone 17 is compact both ways in landscape; the Pro Max is regular wide.
    #expect(
      ScreenLayout(
        size: CGSize(width: 874, height: 402), horizontalSizeClass: .compact,
        verticalSizeClass: .compact) == .panel)
    #expect(
      ScreenLayout(
        size: CGSize(width: 956, height: 440), horizontalSizeClass: .regular,
        verticalSizeClass: .compact) == .panel)
  }

  @Test(arguments: [
    // iPad Pro 11" and 13" and iPad mini in landscape
    (CGSize(width: 1210, height: 834), ScreenLayout.panel),
    (CGSize(width: 1376, height: 1032), .panel),
    (CGSize(width: 1133, height: 744), .panel),
    // the same in portrait
    (CGSize(width: 834, height: 1210), .stacked),
    (CGSize(width: 1032, height: 1376), .stacked),
    (CGSize(width: 744, height: 1133), .stacked),
    // iPhone Duo open, held normally (landscape) and turned
    (CGSize(width: 951, height: 669), .panel),
    (CGSize(width: 669, height: 951), .stacked),
  ])
  func regularWidthFollowsTheShape(size: CGSize, layout: ScreenLayout) {
    #expect(
      ScreenLayout(size: size, horizontalSizeClass: .regular, verticalSizeClass: .regular)
        == layout)
  }

  @Test func iPhoneDuoClosedIsAnIPhone() {
    #expect(
      ScreenLayout(
        size: CGSize(width: 466, height: 678), horizontalSizeClass: .compact,
        verticalSizeClass: .regular) == .compact)
    #expect(
      ScreenLayout(
        size: CGSize(width: 678, height: 466), horizontalSizeClass: .compact,
        verticalSizeClass: .compact) == .panel)
  }

  @Test func aNarrowIPadWindowIsCompact() {
    #expect(
      ScreenLayout(
        size: CGSize(width: 500, height: 834), horizontalSizeClass: .compact,
        verticalSizeClass: .regular) == .compact)
  }
}
