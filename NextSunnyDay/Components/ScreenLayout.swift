import SwiftUI

/// How a screen lays out in the space its window has: never by the device or its orientation.
/// See "iPad and landscape" in `docs/design/spec.md`.
nonisolated enum ScreenLayout: Equatable {
  /// iPhone in portrait and narrow windows: the layered header and sheet.
  case compact
  /// Regular width under `panelMinimumWidth`: the layered header and sheet, with the additions of
  /// the wider layouts.
  case stacked
  /// `panelMinimumWidth` or wider, or compact height: the answer in a panel beside the forecast.
  case panel

  /// Where the 24-hour chart (about 700 pt) fits beside the 420 pt panel.
  static let panelMinimumWidth: CGFloat = 1120

  init(
    width: CGFloat, horizontalSizeClass: UserInterfaceSizeClass?,
    verticalSizeClass: UserInterfaceSizeClass?
  ) {
    if verticalSizeClass == .compact {
      self = .panel
    } else if horizontalSizeClass == .regular {
      self = width >= Self.panelMinimumWidth ? .panel : .stacked
    } else {
      self = .compact
    }
  }

  /// Whether the screen has the temperature chart, the range bars and the answer day's details.
  var isWide: Bool { self != .compact }
}

/// Gives its content the layout for the width of the window it is in.
struct AdaptiveLayout<Content: View>: View {
  @ViewBuilder let content: (ScreenLayout) -> Content

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.verticalSizeClass) private var verticalSizeClass

  var body: some View {
    GeometryReader { proxy in
      content(
        ScreenLayout(
          width: proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing,
          horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass))
    }
  }
}
