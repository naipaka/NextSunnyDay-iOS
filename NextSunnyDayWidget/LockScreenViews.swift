import SunnyDay
import SwiftUI
import Weather
import WidgetKit

/// 「☀ 次の晴れ あと3日（土）」 above the clock; 「☀ 次の晴れ あした」 without the weekday.
struct InlineWidgetView: View {
  let entry: SunnyEntry

  var body: some View {
    Label {
      switch entry.state {
      // 「今日」 and 「あした」 need no weekday.
      case .sunny(let next) where next.daysAway > 1:
        Text("Next Sunny Day \(Text(daysAway: next.daysAway)) (\(next.day.date.weekday))")
      case .sunny(let next):
        Text("Next Sunny Day \(Text(daysAway: next.daysAway))")
      default:
        Text("Next Sunny Day \(entry.state.headline)")
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
          switch next.daysAway {
          case 0: Text("Today")
          case 1: Text("Tomorrow")
          default: Text("\(next.daysAway) days")
          }
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
