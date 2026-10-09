import SwiftUI
import WidgetKit

@main
struct NextSunnyDayWidget: Widget {
  let kind: String = "NextSunnyDayWidget"

  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: kind, intent: SelectRegionIntent.self, provider: Provider()) {
      entry in
      NextSunnyDayWidgetEntryView(entry: entry)
        .containerBackground(for: .widget) {
          WidgetBackground(state: entry.state)
        }
    }
    .configurationDisplayName("NextSunnyDay")
    .description("See when the next sunny day is.")
    .supportedFamilies([
      .systemSmall, .systemMedium, .systemLarge,
      .accessoryInline, .accessoryCircular, .accessoryRectangular,
    ])
  }
}

struct NextSunnyDayWidgetEntryView: View {
  let entry: SunnyEntry

  @Environment(\.widgetFamily) private var family

  var body: some View {
    switch family {
    case .systemMedium: MediumWidgetView(entry: entry).homeScreenStyle()
    case .systemLarge: LargeWidgetView(entry: entry).homeScreenStyle()
    case .accessoryInline: InlineWidgetView(entry: entry)
    case .accessoryCircular: CircularWidgetView(entry: entry)
    case .accessoryRectangular: RectangularWidgetView(entry: entry)
    default: SmallWidgetView(entry: entry).homeScreenStyle()
    }
  }
}

/// Orange or gray on the Home Screen in full color. In the accented and clear looks the system
/// replaces it with its own material; on the Lock Screen it is the standard accessory background.
struct WidgetBackground: View {
  let state: SunnyEntry.State

  @Environment(\.widgetFamily) private var family

  var body: some View {
    switch family {
    case .accessoryCircular, .accessoryRectangular: AccessoryWidgetBackground()
    case .accessoryInline: Color.clear
    default: state.background
    }
  }
}

extension View {
  /// White text and symbols on the colored background.
  fileprivate func homeScreenStyle() -> some View {
    foregroundStyle(.white)
  }
}
