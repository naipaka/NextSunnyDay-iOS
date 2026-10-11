import SunnyDay
import SwiftUI
import Weather

/// When the next sunny day is, or why it isn't known: 「次の晴れ」 over the big answer, the day and
/// its temperatures. Home's header and the panel of the wider layouts show it.
struct HomeAnswer: View {
  let state: HomeHeader.State
  /// Names the answer: the next sunny day or the next laundry day.
  let level: SunnyLevel
  let retry: () -> Void
  /// The size of 「あと4日」; 「まだ先かも」 is smaller.
  var bigSize: CGFloat = 64
  var noneSize: CGFloat = 46
  /// Whether to say until when the sunny run lasts.
  var showsRun = false

  @Environment(TemperatureUnitSelection.self) private var temperatureUnitSelection

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(level.answerTitle)
        .font(.subheadline.weight(.semibold))
        .redacted(reason: isLoading ? .placeholder : [])
      switch state {
      case .loading:
        HStack(spacing: 12) {
          ProgressView().tint(.white).controlSize(.large)
          Text("Getting the weather…").font(.title3.weight(.semibold))
        }
        .frame(height: 76, alignment: .leading)
        Group {
          Text(verbatim: "10/00 (Sat) Clear")
            .font(.headline)
            .padding(.top, 10)
          Text(verbatim: "High 00° Low 00°")
            .font(.subheadline)
        }
        .redacted(reason: .placeholder)
        .accessibilityHidden(true)
      case .noData:
        bigText(Text("In ? days"))
        Text("Couldn't get the weather")
          .font(.headline)
          .padding(.top, 10)
        Button(action: retry) {
          Label("Try Again", systemImage: "arrow.clockwise")
            .foregroundStyle(.black)
        }
        .buttonStyle(.glassProminent)
        .tint(.white)
        .padding(.top, 12)
      case .sunny(let next):
        bigText(daysAway(next.daysAway))
        Label {
          Text(verbatim: "\(next.day.date.dayWithWeekday) \(next.day.condition.localizedName)")
        } icon: {
          Image(systemName: "\(next.day.symbolName).fill")
        }
        .labelStyle(.titleAndIcon)
        .font(.headline)
        .padding(.top, 10)
        Text(
          "High \(next.day.highTemperature.degrees(in: temperatureUnit)) Low \(next.day.lowTemperature.degrees(in: temperatureUnit))"
        )
        .font(.subheadline)
        .padding(.top, 2)
        if showsRun, next.lastsMoreThanADay {
          Text(level.runText(until: next.lastDay.date.dayWithWeekday))
            .font(.headline)
            .padding(.top, 14)
        }
      case .noneInRange:
        bigText(Text("Maybe not for a while"), size: noneSize)
        Text(level.noneInRangeText)
          .font(.headline)
          .padding(.top, 10)
        Text("It shows up here when the forecast changes")
          .font(.subheadline)
          .padding(.top, 2)
      }
    }
  }

  private func bigText(_ text: Text, size: CGFloat? = nil) -> some View {
    text
      .font(.system(size: size ?? bigSize, weight: .bold))
      .lineLimit(1)
      .minimumScaleFactor(0.5)
      .padding(.top, 4)
  }

  private func daysAway(_ days: Int) -> Text {
    days == 1 ? Text("Tomorrow") : Text("In \(days) days")
  }

  private var temperatureUnit: UnitTemperature { temperatureUnitSelection.unit }

  private var isLoading: Bool {
    if case .loading = state { true } else { false }
  }
}
