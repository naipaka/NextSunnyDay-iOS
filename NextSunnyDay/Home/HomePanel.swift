import SunnyDay
import SwiftUI
import Weather

/// Home's panel in the panel layout, in time order: today, the answer, how long the sunny run
/// lasts, and the answer day's details. On iPhone in landscape, today and the answer only.
struct HomePanel: View {
  let state: HomeHeader.State
  let today: DayForecast?
  let level: SunnyLevel
  let retry: () -> Void

  @Environment(\.verticalSizeClass) private var verticalSizeClass

  private var isCompactHeight: Bool { verticalSizeClass == .compact }

  private var answerDay: DayForecast? {
    if case .sunny(let next) = state { next.day } else { nil }
  }

  private var isLoading: Bool {
    if case .loading = state { true } else { false }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: isCompactHeight ? 12 : 22) {
      VStack(alignment: .leading, spacing: isCompactHeight ? 10 : 16) {
        todayRow
        Rectangle()
          .fill(.white.opacity(0.4))
          .frame(height: 1)
      }
      HomeAnswer(
        state: state, level: level, retry: retry,
        bigSize: isCompactHeight ? 50 : 84, noneSize: isCompactHeight ? 40 : 64,
        showsRun: !isCompactHeight)
      if !isCompactHeight {
        Group {
          if isLoading {
            AnswerDayFacts(day: nil, level: level).redacted(reason: .placeholder)
          } else {
            AnswerDayFacts(day: answerDay, level: level)
          }
        }
        .padding(.top, 6)
      }
    }
  }

  /// Today's symbol beside 「今日」 over the condition, sized against the answer as on Home.
  private var todayRow: some View {
    HStack(spacing: isCompactHeight ? 10 : 14) {
      Group {
        if let today {
          Image(systemName: "\(today.symbolName).fill")
        } else if isLoading {
          Image(systemName: "cloud.fill").redacted(reason: .placeholder)
        } else {
          Text(verbatim: "—")
        }
      }
      .font(.system(size: isCompactHeight ? 30 : 50))
      .frame(width: isCompactHeight ? 36 : 60)
      .accessibilityHidden(true)
      VStack(alignment: .leading, spacing: 2) {
        Text("Today")
          .font((isCompactHeight ? Font.footnote : .subheadline).weight(.semibold))
        if let today {
          Text(verbatim: today.condition.localizedName)
            .font((isCompactHeight ? Font.headline : .title3).weight(.semibold))
        } else if isLoading {
          Text(verbatim: "Cloudy").font(.headline).redacted(reason: .placeholder)
        }
      }
    }
    .accessibilityElement(children: .combine)
  }
}
