import Forecast
import SwiftUI
import Weather

/// When the forecast was fetched, and the Apple Weather mark with its legal link, which WeatherKit
/// requires wherever its data is shown.
struct AttributionFooter: View {
  var fetchedAt: Date?

  @Environment(\.forecastUpdater) private var forecastUpdater
  @State private var attribution: WeatherDataAttribution?

  var body: some View {
    VStack(spacing: 6) {
      if let fetchedAt {
        Text("Updated \(fetchedAt.fetchTime)")
      }
      if let attribution {
        AttributionMark(attribution: attribution)
          .frame(height: 14)
        Link("Data Sources", destination: attribution.legalPageURL)
      }
    }
    .font(.footnote)
    .foregroundStyle(.secondary)
    .frame(maxWidth: .infinity)
    .task {
      attribution = try? await forecastUpdater.attribution()
    }
  }
}

/// The Apple Weather mark for the current appearance.
struct AttributionMark: View {
  let attribution: WeatherDataAttribution
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    AsyncImage(
      url: colorScheme == .dark ? attribution.combinedMarkDarkURL : attribution.combinedMarkLightURL
    ) { image in
      image.resizable().scaledToFit()
    } placeholder: {
      Color.clear
    }
    .accessibilityLabel(Text(verbatim: attribution.serviceName))
  }
}
