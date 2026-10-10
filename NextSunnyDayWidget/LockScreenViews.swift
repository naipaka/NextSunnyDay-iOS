import SunnyDay
import SwiftUI
import Weather
import WidgetKit

/// 「☀ 次の晴れ あと3日（土）」 ("Sunny in 3 days (Sat)") above the clock; 「☀ 次の晴れ あした」
/// without the weekday. At the laundry level, 「次の洗濯日和」.
struct InlineWidgetView: View {
  let entry: SunnyEntry

  var body: some View {
    Label {
      // One sentence per state, short enough for the line above the clock in English too.
      if entry.level == .laundry {
        switch entry.state {
        case .sunny(let next) where next.daysAway > 1:
          Text("Laundry day in \(next.daysAway) days (\(next.day.date.weekday))")
        case .sunny:
          Text("Laundry day tomorrow")
        case .noneInRange:
          Text("No laundry day soon")
        case .noData, .noRegion:
          Text("Laundry day in ? days")
        }
      } else {
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

/// 「次の晴れ」 (or 「次の洗濯日和」), 「あと3日」 and the day, and after a thin line, today's symbol.
struct RectangularWidgetView: View {
  let entry: SunnyEntry

  var body: some View {
    HStack(spacing: 8) {
      VStack(alignment: .leading, spacing: 0) {
        Label {
          Text(entry.level.answerTitle)
        } icon: {
          Image(systemName: entry.state.symbolName)
        }
        .font(.caption2.weight(.bold))
        entry.state.headline
          .font(.headline)
          .widgetAccentable()
        entry.state.shortDate
          .font(.caption2)
      }
      .lineLimit(1)
      .minimumScaleFactor(0.7)
      .frame(maxWidth: .infinity, alignment: .leading)
      if let today = entry.today {
        Rectangle()
          .frame(width: 1)
          .opacity(0.5)
          .padding(.vertical, 6)
        VStack(spacing: 2) {
          Text("Today")
            .font(.caption2.weight(.bold))
          Image(systemName: today.symbolName.filledSymbol)
            .font(.title3)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today: \(today.condition.localizedName)"))
      }
    }
  }
}
