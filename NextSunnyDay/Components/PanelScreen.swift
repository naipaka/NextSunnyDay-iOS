import SwiftUI

/// The panel layout of Home and the day detail screen: a colored panel on the leading side, from
/// the screen's edge, with the forecast scrolling beside it.
struct PanelScreen<Panel: View, Content: View>: View {
  let tone: HeaderTone
  /// The day the forecast was last scrolled to, kept by its owner across layouts.
  var scrolledDay: Binding<Date?> = .constant(nil)
  @ViewBuilder let panel: Panel
  @ViewBuilder let content: Content

  @Environment(\.verticalSizeClass) private var verticalSizeClass
  @Environment(\.colorSchemeContrast) private var contrast
  @Environment(\.colorScheme) private var colorScheme
  @State private var leadingInset: CGFloat = 0
  @State private var fold: CGFloat?

  /// The panel's width inside the safe area: 420 pt, or 268 pt on iPhone in landscape, where
  /// the leading inset by the Dynamic Island brings it to 330 pt. On iPhone Duo partially open
  /// like a book, the panel runs to the fold, so the answer and the forecast each have a side.
  private var panelWidth: CGFloat { fold ?? (verticalSizeClass == .compact ? 268 : 420) }

  /// Where the fold divides the screen side by side, while iPhone Duo is partially open, in whole
  /// points: at the fold's 475.5 pt the forecast beside the panel never settled its layout.
  nonisolated private static func fold(in proxy: GeometryProxy) -> CGFloat? {
    guard #available(iOS 27.1, *) else { return nil }
    return proxy.reservedRegions(kind: .division)
      .first { $0.frame.height > $0.frame.width }?
      .frame.midX.rounded()
  }

  private var horizontalPadding: CGFloat { verticalSizeClass == .compact ? 0 : 40 }

  /// On iPhone in landscape the Dynamic Island's inset keeps the panel's text off the edge; where
  /// there is none, as on iPhone Duo closed in landscape, the panel adds the margin itself.
  private var leadingPadding: CGFloat {
    verticalSizeClass == .compact ? max(20 - leadingInset, 0) : horizontalPadding
  }

  var body: some View {
    HStack(spacing: 0) {
      ScrollView {
        panel
          .foregroundStyle(.white)
          .padding(.leading, leadingPadding)
          .padding(.trailing, verticalSizeClass == .compact ? 20 : horizontalPadding)
          .padding(.top, 12)
          .padding(.bottom, 24)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .scrollBounceBehavior(.basedOnSize)
      .frame(width: panelWidth)
      .background {
        Rectangle()
          .fill(tone.fill(increasedContrast: contrast == .increased))
          // With Increase Contrast the dark variants get lighter, which lowers the contrast of the
          // white text; the light variants get darker.
          .environment(\.colorScheme, contrast == .increased ? .light : colorScheme)
          .ignoresSafeArea()
      }
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          content
        }
        .padding(.horizontal, verticalSizeClass == .compact ? 16 : 28)
        .padding(.top, 12)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .keepsScrolledDay(scrolledDay)
      .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
    .onGeometryChange(for: CGFloat.self) {
      $0.safeAreaInsets.leading
    } action: {
      leadingInset = $0
    }
    .onGeometryChange(for: CGFloat?.self) {
      Self.fold(in: $0)
    } action: { newFold in
      // The fold changes without the window resizing, so nothing animates it otherwise.
      withAnimation(.smooth) { fold = newFold }
    }
  }
}
