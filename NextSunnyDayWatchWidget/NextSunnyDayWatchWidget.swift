import SwiftUI
import WidgetKit

/// The complications: the iPhone's Lock Screen widgets on the watch face, plus the corner, with
/// the same provider and the same `kind`.
@main
struct NextSunnyDayWatchWidget: Widget {
  let kind: String = "NextSunnyDayWidget"

  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: kind, intent: SelectRegionIntent.self, provider: Provider()) {
      entry in
      ComplicationView(entry: entry)
        .containerBackground(for: .widget) {
          ComplicationBackground(state: entry.state)
        }
    }
    .configurationDisplayName("NextSunnyDay")
    .description("See when the next sunny day is.")
    .supportedFamilies([
      .accessoryCircular, .accessoryCorner, .accessoryRectangular, .accessoryInline,
    ])
  }
}

struct ComplicationView: View {
  let entry: SunnyEntry

  @Environment(\.widgetFamily) private var family

  var body: some View {
    switch family {
    case .accessoryCorner: CornerWidgetView(entry: entry)
    case .accessoryRectangular: RectangularWidgetView(entry: entry)
    case .accessoryInline: InlineWidgetView(entry: entry)
    default: CircularWidgetView(entry: entry)
    }
  }
}

/// The symbol in the corner, with 「あと3日」 along the bezel.
struct CornerWidgetView: View {
  let entry: SunnyEntry

  var body: some View {
    AccessorySymbol(name: entry.state.symbolName)
      .font(.title2)
      .widgetAccentable()
      .widgetLabel {
        entry.state.headline
          .answerAccent()
      }
  }
}

/// In the Smart Stack, the rectangular complication is orange or gray like the iPhone's widgets;
/// on a watch face the system leaves the background out.
struct ComplicationBackground: View {
  let state: SunnyEntry.State

  @Environment(\.widgetFamily) private var family
  @Environment(\.colorSchemeContrast) private var contrast

  var body: some View {
    switch family {
    case .accessoryRectangular:
      Rectangle().fill(state.background(increasedContrast: contrast == .increased))
    case .accessoryCircular: AccessoryWidgetBackground()
    default: Color.clear
    }
  }
}
