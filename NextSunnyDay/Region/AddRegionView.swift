import Region
import SwiftUI

/// Adds a region and chooses it: the current location, or a place found by search while typing.
/// Onboarding opens it for the first region.
struct AddRegionView: View {
  @Environment(RegionSelection.self) private var regionSelection
  @Environment(\.regionSearch) private var regionSearch
  @Environment(\.dismiss) private var dismiss
  @State private var query = ""
  @State private var candidates: [RegionCandidate] = []
  @State private var isShowingNotFound = false

  var body: some View {
    List {
      if !regionSelection.list.containsCurrentLocation {
        currentLocationSection
      }
      if !candidates.isEmpty {
        Section("Search Results") {
          ForEach(candidates) { candidate in
            Button {
              Task { await select(candidate) }
            } label: {
              HStack {
                VStack(alignment: .leading, spacing: 2) {
                  Text(verbatim: candidate.name)
                  // MapKit gives some places, such as countries' capitals, no area.
                  if !candidate.area.isEmpty {
                    Text(verbatim: candidate.area)
                      .font(.subheadline)
                      .foregroundStyle(.secondary)
                  }
                }
                Spacer()
                if regionSelection.regions.contains(where: { $0.placeName == candidate.name }) {
                  Image(systemName: "checkmark").foregroundStyle(.orange).fontWeight(.semibold)
                }
              }
              .contentShape(Rectangle())
            }
            .tint(.primary)
          }
        }
      }
    }
    .navigationTitle(regionSelection.regions.isEmpty ? "Region" : "Add Region")
    .navigationBarTitleDisplayMode(.inline)
    .searchable(text: $query, prompt: "Search cities")
    .task(id: query) {
      guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
        candidates = []
        return
      }
      // Waits while the user keeps typing; a new character cancels this task.
      try? await Task.sleep(for: .milliseconds(300))
      guard !Task.isCancelled else { return }
      do {
        candidates = try await regionSearch.candidates(for: query)
      } catch {
        if !Task.isCancelled { candidates = [] }
      }
    }
    .alert("Couldn't find this place", isPresented: $isShowingNotFound) {
      Button("OK", role: .cancel) {}
    }
  }

  private var currentLocationSection: some View {
    Section {
      Button {
        regionSelection.addCurrentLocation()
        dismiss()
      } label: {
        Label {
          VStack(alignment: .leading, spacing: 2) {
            Text("Use Current Location")
            Text("Shows the weather where you are")
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
        } icon: {
          Image(systemName: "location.fill").foregroundStyle(.blue)
        }
      }
      .tint(.primary)
    }
  }

  private func select(_ candidate: RegionCandidate) async {
    do {
      try await regionSelection.add(candidate)
      dismiss()
    } catch {
      isShowingNotFound = true
    }
  }
}

#Preview {
  PreviewHost(.tokyo) {
    NavigationStack { AddRegionView() }
  }
}
