import SunnyDay
import SwiftUI
import Weather
import WidgetKit

/// 「☀ 次の晴れ あと3日（土）」 ("Sunny in 3 days (Sat)") above the clock; 「☀ 次の晴れ あした」
/// without the weekday.
struct InlineWidgetView: View {
  let entry: SunnyEntry

  var body: some View {
    Label {
      // One sentence per state, short enough for the line above the clock in English too.
      switch entry.state {
      // 「あした」 needs no weekday.
      case .sunny(let next) where next.daysAway > 1:
        Text("Sunny in \(next.daysAway) days (\(next.day.date.weekday))")
      case .sunny:
        Text("Sunny tomorrow")
      case .noneInRange:
        Text("No sunny day soon")
      case .noData, .noRegion:
        Text("Sunny in ? days")
      }
    } icon: {
      Image(systemName: entry.state.symbolName)
    }
  }
}

/// The symbol over 「3日」.
struct CircularWidgetView: View {
  let entry: SunnyEntry

  var body: some View {
    VStack(spacing: 2) {
      Image(systemName: entry.state.symbolName)
        .font(.title3)
        .widgetAccentable()
      Group {
        switch entry.state {
        case .sunny(let next):
          next.daysAway == 1 ? Text("Tomorrow") : Text("\(next.daysAway) days")
        case .noneInRange: Text(verbatim: "-")
        case .noData, .noRegion: Text(verbatim: "?")
        }
      }
      .font(.headline)
      .lineLimit(1)
      .minimumScaleFactor(0.5)
    }
    .padding(4)
  }
}

/// 「次の晴れ」, 「あと3日」 and the day.
struct RectangularWidgetView: View {
  let entry: SunnyEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Label {
        Text("Next Sunny Day")
      } icon: {
        Image(systemName: entry.state.symbolName)
      }
      .font(.caption2.weight(.bold))
      entry.state.headline
        .font(.headline)
        .widgetAccentable()
      entry.state.shortDetail
        .font(.caption2)
    }
    .lineLimit(1)
    .minimumScaleFactor(0.7)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
