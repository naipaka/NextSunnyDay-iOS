import SunnyDay
import SwiftUI
import Weather

/// The colored header of Home: when the next sunny day is, or why it isn't known, and beside it,
/// smaller, today's weather.
struct HomeHeader: View {
  enum State {
    case loading
    case noData(RegionForecast.Failure)
    case sunny(NextSunnyDay)
    case noneInRange
  }

  let state: State
  /// Today's forecast, `nil` while loading or without data.
  let today: DayForecast?
  /// Names the answer: the next sunny day or the next laundry day.
  let level: SunnyLevel
  let retry: () -> Void

  var body: some View {
    HStack(alignment: .top, spacing: 18) {
      HomeAnswer(state: state, level: level, retry: retry)
        .frame(maxWidth: .infinity, alignment: .leading)
      Rectangle()
        .fill(.white.opacity(0.4))
        .frame(width: 1)
      todayColumn
        .frame(width: 92)
    }
    .fixedSize(horizontal: false, vertical: true)
    .foregroundStyle(.white)
  }

  // MARK: - Today

  @ViewBuilder private var todayColumn: some View {
    VStack(spacing: 10) {
      Text("Today")
        .font(.subheadline.weight(.semibold))
        .redacted(reason: isLoading ? .placeholder : [])
      if let today {
        Image(systemName: "\(today.symbolName).fill")
          .font(.system(size: 40))
          .frame(height: 46)
          .accessibilityHidden(true)
        Text(verbatim: today.condition.localizedName)
          .font(.headline)
          .multilineTextAlignment(.center)
          .lineLimit(2)
          .minimumScaleFactor(0.8)
      } else if isLoading {
        Group {
          Image(systemName: "cloud.fill")
            .font(.system(size: 40))
            .frame(height: 46)
          Text(verbatim: "Cloudy")
            .font(.headline)
        }
        .redacted(reason: .placeholder)
        .accessibilityHidden(true)
      } else {
        Text(verbatim: "—")
          .font(.title2)
          .frame(height: 46)
          .accessibilityHidden(true)
      }
    }
    .accessibilityElement(children: .combine)
  }

  private var isLoading: Bool {
    if case .loading = state { true } else { false }
  }
}
