import SunnyDay
import SwiftUI
import Weather
import WidgetKit

/// 「☀ 次の晴れ あと3日（土）」 ("Sunny in 3 days (Sat)") above the clock; 「☀ 次の晴れ あした」
/// without the weekday. At the laundry level, 「次の洗濯日和」.
struct InlineWidgetView: View {
  let entry: SunnyEntry

  var body: some View {
    // The sentence, or where it doesn't fit (the watch faces' inline slots are shorter than the
    // line above the Lock Screen's clock) the answer alone: 「☀ あと3日」.
    ViewThatFits {
      label(sentence)
      label(entry.state.headline)
    }
  }

  private func label(_ text: Text) -> some View {
    Label {
      text
    } icon: {
      Image(systemName: entry.state.symbolName)
    }
  }

  /// One sentence per state, short enough for the line above the clock in English too.
  private var sentence: Text {
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
  }
}

/// The symbol over 「3日」.
struct CircularWidgetView: View {
  let entry: SunnyEntry

  var body: some View {
    VStack(spacing: 2) {
      AccessorySymbol(name: entry.state.symbolName)
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
      .answerAccent()
    }
    .padding(4)
  }
}

/// 「次の晴れ」 (or 「次の洗濯日和」), 「あと3日」 and the day, and after a thin line, today's symbol.
struct RectangularWidgetView: View {
  let entry: SunnyEntry

  /// Today stays small beside the answer. The watch's text styles are larger for the same
  /// space, so it takes a smaller one there.
  /// The answer is what the complication is glanced at for. On the watch, where today is small,
  /// it takes the room beside it.
  private static var answerFont: Font {
    #if os(watchOS)
      .title2.weight(.semibold)
    #else
      .headline
    #endif
  }

  private static var todaySymbolFont: Font {
    #if os(watchOS)
      .body
    #else
      .title3
    #endif
  }

  var body: some View {
    HStack(spacing: 8) {
      VStack(alignment: .leading, spacing: 0) {
        Label {
          Text(entry.level.answerTitle)
        } icon: {
          AccessorySymbol(name: entry.state.symbolName)
        }
        .font(.caption2.weight(.bold))
        entry.state.headline
          .font(Self.answerFont)
          .minimumScaleFactor(0.5)
          .layoutPriority(1)
          .widgetAccentable()
          .answerAccent()
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
          AccessorySymbol(name: today.symbolName.filledSymbol)
            .font(Self.todaySymbolFont)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today: \(today.condition.localizedName)"))
      }
    }
  }
}

/// A weather or state symbol. On the watch's full-color faces it has its own colors, like the
/// system's weather complications. Elsewhere it is one color: the system's on the Lock Screen and
/// in tinted faces, and white on the orange or gray background in the Smart Stack, where a yellow
/// sun would be lost.
struct AccessorySymbol: View {
  let name: String

  @Environment(\.widgetRenderingMode) private var renderingMode
  @Environment(\.showsWidgetContainerBackground) private var showsBackground

  var body: some View {
    Image(systemName: name)
      .symbolRenderingMode(
        renderingMode == .fullColor && !showsBackground ? .multicolor : .monochrome)
  }
}

extension View {
  /// The answer in the app's orange on a full-color watch face, as the app's own accent. Elsewhere
  /// the system's color: one color on the Lock Screen and in tinted faces, and white on the
  /// orange or gray background in the Smart Stack.
  func answerAccent() -> some View {
    modifier(AnswerAccent())
  }
}

private struct AnswerAccent: ViewModifier {
  @Environment(\.widgetRenderingMode) private var renderingMode
  @Environment(\.showsWidgetContainerBackground) private var showsBackground

  func body(content: Content) -> some View {
    if renderingMode == .fullColor, !showsBackground {
      content.foregroundStyle(.orange)
    } else {
      content
    }
  }
}
