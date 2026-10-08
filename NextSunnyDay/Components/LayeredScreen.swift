import SwiftUI

/// A colored header with a content sheet over its bottom edge, as on Home and the day detail
/// screen. Both scroll together: scrolling up, the header moves slower than the sheet (parallax)
/// and fades; pulling down stretches the header color into the space above it.
struct LayeredScreen<Header: View, Content: View>: View {
  let color: Color
  @ViewBuilder let header: Header
  @ViewBuilder let content: Content

  @State private var offset: CGFloat = 0
  @State private var headerHeight: CGFloat = 300
  @State private var topInset: CGFloat = 0
  @Environment(\.colorSchemeContrast) private var contrast
  @Environment(\.colorScheme) private var colorScheme
  private let overlap: CGFloat = 34

  var body: some View {
    let scrolledUp = max(offset, 0)
    ScrollView {
      VStack(spacing: -overlap) {
        header
          .padding(.horizontal, 20)
          .padding(.top, 24)
          .padding(.bottom, 32 + overlap)
          .onGeometryChange(for: CGFloat.self) {
            $0.size.height
          } action: {
            headerHeight = $0
          }
          .opacity(Double(max(0, 1 - scrolledUp / max(headerHeight * 0.7, 1))))
          .frame(maxWidth: .infinity, alignment: .leading)
          .offset(y: scrolledUp * 0.7)
        VStack(alignment: .leading, spacing: 24) {
          content
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
          UnevenRoundedRectangle(
            topLeadingRadius: overlap, topTrailingRadius: overlap, style: .continuous
          )
          .fill(Color(.systemGroupedBackground))
          .padding(.bottom, -1000)
          .shadow(color: .black.opacity(0.18), radius: 18, y: -4)
        }
      }
    }
    .onScrollGeometryChange(for: CGFloat.self) {
      $0.contentOffset.y + $0.contentInsets.top
    } action: { _, new in
      offset = new
    }
    .onScrollGeometryChange(for: CGFloat.self) {
      $0.contentInsets.top
    } action: { _, new in
      topInset = new
    }
    .background {
      // Behind the scroll view, so that the refresh control shows on it. It ends under the
      // sheet: pulling down stretches it, and it is gone once the sheet reaches the top.
      VStack(spacing: 0) {
        color
          .frame(height: max(topInset + headerHeight - offset, 0))
          // With Increase Contrast the dark variants get lighter, which lowers the contrast of
          // the white header text; the light variants get darker.
          .environment(\.colorScheme, contrast == .increased ? .light : colorScheme)
        Color(.systemGroupedBackground)
      }
      .ignoresSafeArea()
    }
  }
}

/// A titled card in the content sheet.
struct CardSection<Content: View>: View {
  let title: LocalizedStringKey
  @ViewBuilder let content: Content

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 16)
      content
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
          Color(.secondarySystemGroupedBackground),
          in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
  }
}
