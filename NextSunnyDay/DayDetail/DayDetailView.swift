import Forecast
import SunnyDay
import SwiftUI
import Weather

/// One day of the forecast: its hours and more. The toolbar moves to the previous or next day.
struct DayDetailView: View {
  @Environment(RegionForecast.self) private var regionForecast
  @Environment(SunnyLevelSelection.self) private var sunnyLevelSelection
  @Environment(TemperatureUnitSelection.self) private var temperatureUnitSelection
  @State private var index: Int

  init(initialIndex: Int) {
    _index = State(initialValue: initialIndex)
  }

  /// The same days as Home's list, which the index refers to.
  private var days: [DayForecast] { regionForecast.forecast?.forecast.days(from: .now) ?? [] }

  private var temperatureUnit: UnitTemperature { temperatureUnitSelection.unit }

  var body: some View {
    if days.indices.contains(index) {
      let day = days[index]
      LayeredScreen(tone: sunnyLevelSelection.level.counts(day) ? .sunny : .gray) {
        header(day)
      } content: {
        HoursCard(hours: hours(of: day))
        MoreCard(day: day)
        AttributionFooter(fetchedAt: regionForecast.forecast?.fetchedAt)
      }
      .toolbar {
        ToolbarItemGroup(placement: .topBarTrailing) {
          Button("Previous Day", systemImage: "chevron.up") { index -= 1 }
            .disabled(index == 0)
          Button("Next Day", systemImage: "chevron.down") { index += 1 }
            .disabled(index == days.count - 1)
        }
      }
    } else {
      ContentUnavailableView("No Forecast", systemImage: "cloud")
    }
  }

  private func hours(of day: DayForecast) -> [HourForecast] {
    let hourly = regionForecast.forecast?.forecast.hourly ?? []
    return hourly.filter { Calendar.current.isDate($0.date, inSameDayAs: day.date) }
  }

  private func header(_ day: DayForecast) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(verbatim: day.date.dayWithWeekday)
        .font(.headline)
      Text(verbatim: day.condition.localizedName)
        .font(.system(size: 56, weight: .bold))
        .lineLimit(1)
        .minimumScaleFactor(0.5)
      Text(
        "High \(day.highTemperature.degrees(in: temperatureUnit)) Low \(day.lowTemperature.degrees(in: temperatureUnit)) Rain \(day.precipitationChance.percent)"
      )
      .font(.subheadline)
      .opacity(0.9)
      .padding(.top, 4)
    }
    .foregroundStyle(.white)
    .frame(maxWidth: .infinity, alignment: .leading)
    .overlay(alignment: .topTrailing) {
      Image(systemName: "\(day.symbolName).fill")
        .font(.system(size: 64))
        .foregroundStyle(.white.opacity(0.95))
        .accessibilityHidden(true)
    }
  }
}

/// One row per hour of the day.
private struct HoursCard: View {
  let hours: [HourForecast]
  @ScaledMetric private var timeWidth: CGFloat = 44
  @ScaledMetric private var symbolWidth: CGFloat = 32
  @ScaledMetric private var temperatureWidth: CGFloat = 40
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(TemperatureUnitSelection.self) private var temperatureUnitSelection

  private var temperatureUnit: UnitTemperature { temperatureUnitSelection.unit }

  var body: some View {
    CardSection(title: "Hourly") {
      VStack(spacing: 0) {
        ForEach(Array(hours.enumerated()), id: \.element.date) { index, hour in
          row(hour)
            .accessibilityElement(children: .combine)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
          if index != hours.count - 1 {
            Divider().padding(.leading, 16)
          }
        }
      }
      .padding(.vertical, 4)
    }
  }

  /// At accessibility sizes the condition and the chance of rain go on a second line.
  @ViewBuilder private func row(_ hour: HourForecast) -> some View {
    if dynamicTypeSize.isAccessibilitySize {
      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 14) {
          time(hour)
          Spacer()
          temperature(hour)
        }
        HStack(spacing: 14) {
          condition(hour)
          precipitation(hour)
        }
      }
    } else {
      HStack(spacing: 14) {
        time(hour)
        condition(hour)
        Spacer()
        precipitation(hour)
        temperature(hour)
      }
    }
  }

  private func time(_ hour: HourForecast) -> some View {
    HStack(spacing: 14) {
      Text(verbatim: hour.date.hour)
        .monospacedDigit()
        .frame(minWidth: timeWidth, alignment: .leading)
      WeatherSymbol(name: hour.symbolName)
        .font(.title3)
        .frame(width: symbolWidth)
    }
  }

  private func condition(_ hour: HourForecast) -> some View {
    Text(verbatim: hour.condition.localizedName)
      .foregroundStyle(.secondary)
  }

  @ViewBuilder private func precipitation(_ hour: HourForecast) -> some View {
    if hour.precipitationChance.isShownAsPrecipitation {
      Text(verbatim: hour.precipitationChance.percent)
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.cyan)
        .accessibilityLabel(Text("Chance of rain \(hour.precipitationChance.percent)"))
    }
  }

  private func temperature(_ hour: HourForecast) -> some View {
    Text(verbatim: hour.temperature.degrees(in: temperatureUnit))
      .monospacedDigit()
      .frame(minWidth: temperatureWidth, alignment: .trailing)
  }
}

/// Sunrise, sunset, UV index and wind.
private struct MoreCard: View {
  let day: DayForecast
  @ScaledMetric private var symbolWidth: CGFloat = 28

  var body: some View {
    CardSection(title: "More") {
      VStack(spacing: 0) {
        row(
          "sunrise.fill", "Sunrise",
          day.sunrise.map { Text(verbatim: $0.time) } ?? Text(verbatim: "—"))
        Divider().padding(.leading, 52)
        row(
          "sunset.fill", "Sunset", day.sunset.map { Text(verbatim: $0.time) } ?? Text(verbatim: "—")
        )
        Divider().padding(.leading, 52)
        row("sun.max.trianglebadge.exclamationmark", "UV Index", Text(verbatim: "\(day.uvIndex)"))
        Divider().padding(.leading, 52)
        row(
          "wind", "Wind",
          Text(
            "\(day.windDirection.compassDirection) \(day.windSpeed.formatted(.measurement(width: .abbreviated, usage: .wind, numberFormatStyle: .number.precision(.fractionLength(0)))))"
          ))
      }
      .padding(.vertical, 4)
    }
  }

  private func row(_ symbol: String, _ title: LocalizedStringKey, _ value: Text) -> some View {
    HStack(spacing: 12) {
      Image(systemName: symbol)
        .symbolRenderingMode(.multicolor)
        .font(.title3)
        .frame(width: symbolWidth)
      Text(title)
      Spacer()
      value.foregroundStyle(.secondary)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
  }
}

#Preview {
  PreviewHost(.tokyo) {
    NavigationStack { DayDetailView(initialIndex: 1) }
  }
}
