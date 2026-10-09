import Forecast
import Region
import SwiftUI

/// The saved regions: tapping one shows it on Home; Edit removes and reorders them. Home's region
/// menu lists them in this order.
struct RegionListView: View {
  @Environment(RegionSelection.self) private var regionSelection
  @Environment(\.forecastUpdater) private var forecastUpdater
  @Environment(\.dismiss) private var dismiss
  /// The reverse geocoded name of the current location, from its last forecast.
  @State private var currentLocationName: String?

  var body: some View {
    List {
      Section {
        ForEach(regionSelection.regions) { region in
          Button {
            regionSelection.select(region)
            dismiss()
          } label: {
            HStack {
              name(of: region)
              Spacer()
              if region.id == regionSelection.region?.id {
                Image(systemName: "checkmark").foregroundStyle(.orange).fontWeight(.semibold)
              }
            }
            .contentShape(Rectangle())
          }
          .tint(.primary)
          .deleteDisabled(!regionSelection.list.canRemove)
        }
        .onDelete { regionSelection.remove(atOffsets: $0) }
        .onMove { regionSelection.move(fromOffsets: $0, toOffset: $1) }
      } footer: {
        Text("You can save up to \(RegionList.maximumCount) regions.")
      }
      Section {
        NavigationLink {
          AddRegionView()
        } label: {
          Label("Add Region", systemImage: "plus")
        }
        .disabled(regionSelection.list.isFull)
      }
    }
    .navigationTitle("Regions")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar { EditButton() }
    .onAppear {
      currentLocationName =
        forecastUpdater.cached(regionID: SavedRegion.currentLocationID)?
        .placeName
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
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
      }
    }
  }
}

#Preview {
  PreviewHost(.severalRegions) {
    NavigationStack { RegionListView() }
  }
}
