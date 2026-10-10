import Forecast
import Region
import SwiftUI

/// The saved regions in the iPhone's order, to choose the one the watch shows, worded as the
/// iPhone's region list. Regions are added and removed on the iPhone.
struct RegionPicker: View {
  @Environment(SyncedSettings.self) private var settings
  @Environment(\.forecastUpdater) private var forecastUpdater
  @Environment(\.dismiss) private var dismiss
  /// The reverse geocoded name of the current location, from its last forecast.
  @State private var currentLocationName: String?

  var body: some View {
    NavigationStack {
      List(settings.regions, id: \.id) { region in
        Button {
          settings.select(region)
          dismiss()
        } label: {
          HStack {
            name(of: region)
            Spacer()
            if region.id == settings.region?.id {
              Image(systemName: "checkmark")
                .foregroundStyle(.orange)
                .accessibilityLabel(Text("Selected"))
            }
          }
        }
      }
      .navigationTitle("Regions")
    }
    .onAppear {
      currentLocationName =
        forecastUpdater.cached(regionID: SavedRegion.currentLocationID)?.placeName
    }
  }

  @ViewBuilder private func name(of region: SavedRegion) -> some View {
    if let name = region.placeName {
      Text(verbatim: name)
    } else {
      VStack(alignment: .leading, spacing: 2) {
        HStack(spacing: 4) {
          Text("Current Location")
          Image(systemName: "location.fill").font(.caption)
        }
        if let currentLocationName {
          Text(verbatim: currentLocationName)
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
      }
    }
  }
}

#Preview {
  WatchPreviewHost(.severalRegions) {
    RegionPicker()
  }
}
