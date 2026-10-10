import SunnyDay
import SwiftUI
import Weather

/// What Siri and Shortcuts show with the answer: the small widget's layout, with high and low.
struct SunnyDaySnippet: View {
  let answer: SunnyDayAnswer
  let temperatureUnit: UnitTemperature

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack(alignment: .top) {
        Text("Next Sunny Day")
          .font(.subheadline.weight(.semibold))
        Spacer(minLength: 8)
        Image(systemName: symbol)
          .font(.title)
          .accessibilityHidden(true)
      }
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
    .foregroundStyle(.white)
    .padding(20)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(background, in: .rect(cornerRadius: 26))
  }

  @ViewBuilder private var headline: some View {
    switch answer {
    case .noRegion, .noData: Text("In ? days")
    case .sunny(let next, _):
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
    case .sunny(let next, _):
      Text(verbatim: "\(next.day.date.dayWithWeekday) \(next.day.condition.localizedName)")
        .font(.headline)
      Text(
        "High \(next.day.highTemperature.degrees(in: temperatureUnit)) Low \(next.day.lowTemperature.degrees(in: temperatureUnit)) Rain \(next.day.precipitationChance.percent)"
      )
      .font(.subheadline)
      .opacity(0.9)
    case .noneInRange:
      Text("No sunny day in the next 10 days")
        .font(.headline)
    }
  }

  private var placeName: String? {
    switch answer {
    case .noRegion, .noData: nil
    case .sunny(_, let placeName), .noneInRange(let placeName):
      placeName ?? String(localized: "Current Location")
    }
  }

  private var symbol: String {
    switch answer {
    case .noRegion, .noData: "icloud.slash.fill"
    case .sunny(let next, _): "\(next.day.symbolName).fill"
    case .noneInRange: "cloud.fill"
    }
  }

  private var background: Color {
    switch answer {
    case .sunny: .orange
    case .noneInRange: Color(.systemGray)
    case .noRegion, .noData: Color(.systemGray2)
    }
  }
}
