import SwiftUI

/// How a screen lays out in the space its window has: never by the device or its orientation.
/// See "iPad and landscape" in `docs/design/spec.md`.
nonisolated enum ScreenLayout: Equatable {
  /// iPhone in portrait and narrow windows: the layered header and sheet.
  case compact
  /// Regular width, taller than wide: the layered header and sheet, with the additions of the
  /// wider layouts.
  case stacked
  /// Regular width and wider than tall, or compact height: the answer in a panel beside the
  /// forecast.
  case panel

  /// `size` is the whole window's, safe areas included. iPad in landscape and iPhone Duo open in
  /// landscape get the panel, iPad in portrait and iPhone Duo open in portrait the stacked layout.
  init(
    size: CGSize, horizontalSizeClass: UserInterfaceSizeClass?,
    verticalSizeClass: UserInterfaceSizeClass?
  ) {
    if verticalSizeClass == .compact {
      self = .panel
    } else if horizontalSizeClass == .regular {
      self = size.width > size.height ? .panel : .stacked
    } else {
      self = .compact
    }
  }

  /// Whether the screen has the temperature chart, the range bars and the answer day's details.
  var isWide: Bool { self != .compact }
}

/// Gives its content the layout for the size of the window it is in.
struct AdaptiveLayout<Content: View>: View {
  @ViewBuilder let content: (ScreenLayout) -> Content

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.verticalSizeClass) private var verticalSizeClass

  var body: some View {
    GeometryReader { proxy in
      content(
        ScreenLayout(
          size: CGSize(
            width: proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing,
            height: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom),
          horizontalSizeClass: horizontalSizeClass, verticalSizeClass: verticalSizeClass))
    }
  }
}

extension View {
  /// Keeps the toolbar and the status bar along the top where iPhone Duo would put them on the
  /// trailing edge. Home and the day detail screen have a few buttons in the top row, which the
  /// bars share at no cost in height; on the edge, the bars would leave an empty column beside the
  /// content for the screen's full height.
  @ViewBuilder func barsAlongTheTop() -> some View {
    if #available(iOS 27.1, *) {
      toolbarVerticalBehavior(.disabled)
    } else {
      self
    }
  }
}
