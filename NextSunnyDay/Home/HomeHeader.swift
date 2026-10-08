import SunnyDay
import SwiftUI
import Weather

/// The colored header of Home: when the next sunny day is, or why it isn't known.
struct HomeHeader: View {
  enum State {
    case loading
    case noData(RegionForecast.Failure)
    case sunny(NextSunnyDay)
    case noneInRange
  }

  let state: State
  let retry: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("The next sunny day is")
        .font(.headline)
      switch state {
      case .loading:
        HStack(spacing: 12) {
          ProgressView().tint(.white).controlSize(.large)
          Text("Getting the weather…").font(.title2.weight(.semibold))
        }
        .frame(height: 86, alignment: .leading)
      case .noData:
        bigText(Text("In ? days"))
        Text("Couldn't get the weather")
          .font(.title3.weight(.semibold))
          .padding(.top, 6)
        Button(action: retry) {
          Label("Try Again", systemImage: "arrow.clockwise")
            .foregroundStyle(.black)
        }
        .buttonStyle(.glassProminent)
        .tint(.white)
        .padding(.top, 10)
      case .sunny(let next):
        bigText(daysAway(next.daysAway))
        Text(verbatim: "\(next.day.date.dayWithWeekday) \(next.day.condition.localizedName)")
          .font(.title3.weight(.semibold))
          .padding(.top, 6)
        Text(
          "High \(next.day.highTemperature.degrees) Low \(next.day.lowTemperature.degrees) Rain \(next.day.precipitationChance.percent)"
        )
        .font(.subheadline)
        .opacity(0.9)
      case .noneInRange:
        bigText(Text("Maybe not for a while"), size: 52)
        Text("No sunny day in the next 10 days")
          .font(.title3.weight(.semibold))
          .padding(.top, 6)
        Text("It shows up here when the forecast changes")
          .font(.subheadline)
          .opacity(0.9)
      }
    }
    .foregroundStyle(.white)
    .frame(maxWidth: .infinity, alignment: .leading)
    .overlay(alignment: .topTrailing) {
      if let symbol {
        Image(systemName: symbol)
          .font(.system(size: 64))
          .foregroundStyle(.white.opacity(0.95))
          .offset(y: -6)
          .accessibilityHidden(true)
      }
    }
  }

  private var symbol: String? {
    switch state {
    case .loading: nil
    case .noData: "icloud.slash.fill"
    case .sunny(let next): "\(next.day.symbolName).fill"
    case .noneInRange: "cloud.fill"
    }
  }

  private func daysAway(_ days: Int) -> Text {
    switch days {
    case 0: Text("Today")
    case 1: Text("Tomorrow")
    default: Text("In \(days) days")
    }
  }

  private func bigText(_ text: Text, size: CGFloat = 72) -> some View {
    text
      .font(.system(size: size, weight: .bold))
      .lineLimit(1)
      .minimumScaleFactor(0.6)
  }
}
