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
  let retry: () -> Void

  @Environment(TemperatureUnitSelection.self) private var temperatureUnitSelection

  var body: some View {
    HStack(alignment: .top, spacing: 18) {
      answer
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

  // MARK: - The answer

  @ViewBuilder private var answer: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("Next Sunny Day")
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
      case .noneInRange:
        bigText(Text("Maybe not for a while"), size: 46)
        Text("No sunny day in the next 10 days")
          .font(.headline)
          .padding(.top, 10)
        Text("It shows up here when the forecast changes")
          .font(.subheadline)
          .padding(.top, 2)
      }
    }
  }

  private func bigText(_ text: Text, size: CGFloat = 64) -> some View {
    text
      .font(.system(size: size, weight: .bold))
      .lineLimit(1)
      .minimumScaleFactor(0.5)
      .padding(.top, 4)
  }

  private func daysAway(_ days: Int) -> Text {
    days == 1 ? Text("Tomorrow") : Text("In \(days) days")
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

  private var temperatureUnit: UnitTemperature { temperatureUnitSelection.unit }

  private var isLoading: Bool {
    if case .loading = state { true } else { false }
  }
}
