import SwiftUI

/// A colored header fixed behind a content sheet that scrolls over it, as on Home and the day
/// detail screen. While the sheet scrolls, the header fades and moves up slower (parallax).
struct LayeredScreen<Header: View, Content: View>: View {
  let color: Color
  @ViewBuilder let header: Header
  @ViewBuilder let content: Content

  @State private var offset: CGFloat = 0
  @State private var headerHeight: CGFloat = 300
  private let overlap: CGFloat = 34

  var body: some View {
    ZStack(alignment: .top) {
      color.ignoresSafeArea()
      header
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 32 + overlap)
        .onGeometryChange(for: CGFloat.self) {
          $0.size.height
        } action: {
          headerHeight = $0
        }
        .opacity(Double(max(0, 1 - max(offset, 0) / max(headerHeight * 0.7, 1))))
        .offset(y: -max(offset, 0) * 0.3)
      ScrollView {
        VStack(spacing: 0) {
          Color.clear.frame(height: max(headerHeight - overlap, 0))
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
