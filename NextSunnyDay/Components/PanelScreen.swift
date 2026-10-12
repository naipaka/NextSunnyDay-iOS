import SwiftUI

/// The panel layout of Home and the day detail screen: a colored panel on the leading side, from
/// the screen's edge, with the forecast scrolling beside it.
struct PanelScreen<Panel: View, Content: View>: View {
  let tone: HeaderTone
  @ViewBuilder let panel: Panel
  @ViewBuilder let content: Content

  @Environment(\.verticalSizeClass) private var verticalSizeClass
  @Environment(\.colorSchemeContrast) private var contrast
  @Environment(\.colorScheme) private var colorScheme
  @State private var leadingInset: CGFloat = 0

  /// The panel's width inside the safe area: 420 pt, or 268 pt on iPhone in landscape, where
  /// the leading inset by the Dynamic Island brings it to 330 pt.
  private var panelWidth: CGFloat { verticalSizeClass == .compact ? 268 : 420 }

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
      .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
    .onGeometryChange(for: CGFloat.self) {
      $0.safeAreaInsets.leading
    } action: {
      leadingInset = $0
    }
  }
}
