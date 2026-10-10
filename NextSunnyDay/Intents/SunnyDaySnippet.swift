import CoreLocation
import Forecast
import Region
import SunnyDay
import SwiftUI
import Weather
import WeatherTesting

/// What Siri and Shortcuts show with the answer: Home's header on a card, the answer with high
/// and low and the region, and beside it today's weather.
struct SunnyDaySnippet: View {
  let answer: SunnyDayAnswer
  let temperatureUnit: UnitTemperature

  @Environment(\.colorSchemeContrast) private var contrast

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      VStack(alignment: .leading, spacing: 2) {
        Text(level.answerTitle)
          .font(.subheadline.weight(.semibold))
        headline
          .font(.system(size: 44, weight: .bold))
          .lineLimit(1)
          .minimumScaleFactor(0.6)
        detail
        if let placeName {
          Text(verbatim: placeName)
            .font(.footnote)
            .opacity(0.85)
            .padding(.top, 4)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      Rectangle()
        .fill(.white.opacity(0.4))
        .frame(width: 1)
      todayColumn
        .frame(width: 84)
    }
    .fixedSize(horizontal: false, vertical: true)
    .foregroundStyle(.white)
    .padding(20)
    .background(tone.fill(increasedContrast: contrast == .increased), in: .rect(cornerRadius: 26))
  }

  @ViewBuilder private var headline: some View {
    switch answer {
    case .noRegion, .noData: Text("In ? days")
    case .sunny(let next, _, _, _):
      next.daysAway == 1 ? Text("Tomorrow") : Text("In \(next.daysAway) days")
    case .noneInRange: Text("Maybe not for a while")
    }
  }

  @ViewBuilder private var detail: some View {
    switch answer {
    case .noRegion:
      Text("Choose a region in the app")
        .font(.headline)
    case .noData:
      Text("Couldn't get the weather")
        .font(.headline)
    case .sunny(let next, _, _, _):
      Label {
        Text(verbatim: "\(next.day.date.dayWithWeekday) \(next.day.condition.localizedName)")
      } icon: {
        Image(systemName: "\(next.day.symbolName).fill")
      }
      .labelStyle(.titleAndIcon)
      .font(.headline)
      Text(
        "High \(next.day.highTemperature.degrees(in: temperatureUnit)) Low \(next.day.lowTemperature.degrees(in: temperatureUnit))"
      )
      .font(.subheadline)
    case .noneInRange:
      Text(level.noneInRangeText)
        .font(.headline)
    }
  }

  /// 「今日」, today's symbol and its condition, or 「—」 when today isn't in the forecast.
  private var todayColumn: some View {
    VStack(spacing: 8) {
      Text("Today")
        .font(.subheadline.weight(.semibold))
      if let today {
        Image(systemName: "\(today.symbolName).fill")
          .font(.system(size: 34))
          .accessibilityHidden(true)
        Text(verbatim: today.condition.localizedName)
          .font(.subheadline.weight(.semibold))
          .multilineTextAlignment(.center)
          .lineLimit(2)
          .minimumScaleFactor(0.8)
      } else {
        Text(verbatim: "—")
          .font(.title2)
          .accessibilityHidden(true)
      }
    }
    .accessibilityElement(children: .combine)
  }

  private var today: DayForecast? {
    switch answer {
    case .noRegion, .noData: nil
    case .sunny(_, _, let today, _), .noneInRange(_, let today, _): today
    }
  }

  /// The default level while there is no answer, so the label reads 「次の晴れ」.
  private var level: SunnyLevel {
    switch answer {
    case .noRegion, .noData: .default
    case .sunny(_, _, _, let level), .noneInRange(_, _, let level): level
    }
  }

  private var placeName: String? {
    switch answer {
    case .noRegion, .noData: nil
    case .sunny(_, let placeName, _, _), .noneInRange(let placeName, _, _):
      placeName ?? String(localized: "Current Location")
    }
  }

  private var tone: HeaderTone {
    switch answer {
    case .sunny: .sunny
    case .noneInRange: .gray
    case .noRegion, .noData: .noData
    }
  }
}

#Preview("Snippet") {
  let minato = SavedRegion.place(
    name: "港区", coordinate: CLLocationCoordinate2D(latitude: 35.658, longitude: 139.751))
  let cached = { (recording: WeatherRecording) in
    CachedForecast(
      regionID: minato.id, placeName: nil, coordinate: recording.coordinate, fetchedAt: .now,
      forecast: recording.forecast())
  }
  let answers: [SunnyDayAnswer] = [
    SunnyDayAnswer(region: minato, forecast: cached(.tokyo), level: .default),
    SunnyDayAnswer(region: minato, forecast: cached(.singapore), level: .default),
    SunnyDayAnswer(region: minato, forecast: cached(.tokyo), level: .laundry),
    .noData,
    .noRegion,
  ]
  ScrollView {
    VStack(spacing: 16) {
      ForEach(answers.indices, id: \.self) { index in
        SunnyDaySnippet(answer: answers[index], temperatureUnit: .celsius)
      }
    }
    .padding()
  }
}
