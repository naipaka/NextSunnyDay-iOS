import SunnyDay
import SwiftUI

/// Chooses which days count as sunny.
struct SunnyLevelView: View {
  @Environment(SunnyLevelSelection.self) private var sunnyLevelSelection

  var body: some View {
    List {
      Section {
        ForEach(SunnyLevel.allCases, id: \.self) { level in
          Button {
            sunnyLevelSelection.select(level)
          } label: {
            HStack(spacing: 14) {
              WeatherSymbol(name: level.symbolName)
                .font(.title2)
                .frame(width: 34)
              VStack(alignment: .leading, spacing: 2) {
                Text(level.title)
                  .foregroundStyle(.primary)
                Text(level.detail)
                  .font(.subheadline)
                  .foregroundStyle(.secondary)
              }
              Spacer()
              if level == sunnyLevelSelection.level {
                Image(systemName: "checkmark")
                  .fontWeight(.semibold)
                  .foregroundStyle(.orange)
              }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
        }
      } footer: {
        Text(
          "Lower levels are looser. Looking for a day to dry the laundry? Try “No rain is fine”.")
      }
    }
    .navigationTitle("What Counts as Sunny")
    .navigationBarTitleDisplayMode(.inline)
  }
}

extension SunnyLevel {
  var title: LocalizedStringResource {
    switch self {
    case .clear: "Clear only"
    case .mostlyClear: "Sunny"
    case .partlyCloudy: "Up to partly cloudy"
    case .noRain: "No rain is fine"
    }
  }

  var detail: LocalizedStringResource {
    switch self {
    case .clear: "Days with almost no clouds"
    case .mostlyClear: "Clear and mostly clear"
    case .partlyCloudy: "Clear, mostly clear and partly cloudy"
    case .noRain: "Cloudy days too, with a chance of rain under 30%"
    }
  }

  var symbolName: String {
    switch self {
    case .clear: "sun.max"
    case .mostlyClear: "sun.min"
    case .partlyCloudy: "cloud.sun"
    case .noRain: "cloud"
    }
  }
}

#Preview {
  PreviewHost(.tokyo) {
    NavigationStack { SunnyLevelView() }
  }
}
