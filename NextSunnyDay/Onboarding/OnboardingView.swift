import SwiftUI

/// Shown until the user chooses a region.
struct OnboardingView: View {
  @Environment(RegionSelection.self) private var regionSelection

  var body: some View {
    NavigationStack {
      ContentUnavailableView {
        Label("Where should I check the weather?", systemImage: "sun.max.fill")
          .symbolRenderingMode(.multicolor)
      } description: {
        Text("Choose a region to see when it will be sunny next.")
      } actions: {
        VStack(spacing: 12) {
          Button {
            regionSelection.addCurrentLocation()
          } label: {
            Label("Use Current Location", systemImage: "location.fill")
              .frame(maxWidth: 240)
          }
          .buttonStyle(.glassProminent)
          .tint(.orange)
          NavigationLink {
            AddRegionView()
          } label: {
            Label("Search for a Region", systemImage: "magnifyingglass")
              .frame(maxWidth: 240)
          }
          .buttonStyle(.glass)
        }
        .controlSize(.large)
      }
      .navigationTitle("NextSunnyDay")
    }
  }
}

#Preview {
  PreviewHost(.noRegion)
}
