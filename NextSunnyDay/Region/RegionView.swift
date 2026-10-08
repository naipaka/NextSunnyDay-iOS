import Region
import SwiftUI

/// Chooses the region: the current location, or a place found by search while typing.
struct RegionView: View {
  @Environment(RegionSelection.self) private var regionSelection
  @Environment(\.regionSearch) private var regionSearch
  @Environment(\.dismiss) private var dismiss
  @State private var query = ""
  @State private var candidates: [RegionCandidate] = []
  @State private var isShowingNotFound = false

  var body: some View {
    List {
      Section {
        Button {
          regionSelection.useCurrentLocation()
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
      if !candidates.isEmpty {
        Section("Search Results") {
          ForEach(candidates) { candidate in
            Button {
              Task { await select(candidate) }
            } label: {
              HStack {
                VStack(alignment: .leading, spacing: 2) {
                  Text(verbatim: candidate.name)
                  Text(verbatim: candidate.area)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                Spacer()
                if candidate.name == regionSelection.region?.placeName {
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
    .navigationTitle("Region")
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

  private func select(_ candidate: RegionCandidate) async {
    do {
      try await regionSelection.select(candidate)
      dismiss()
    } catch {
      isShowingNotFound = true
    }
  }
}

#Preview {
  PreviewHost(.tokyo) {
    NavigationStack { RegionView() }
  }
}
