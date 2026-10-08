import SunnyDay
import SwiftUI
import Weather

/// The next 24 hours, starting with the current one. The first hour of a day shows its date.
struct NextHoursCard: View {
  let hours: [HourForecast]

  private var shownHours: [HourForecast] {
    let thisHour = Calendar.current.dateInterval(of: .hour, for: .now)?.start ?? .now
    return Array(hours.filter { $0.date >= thisHour }.prefix(24))
  }

  var body: some View {
    CardSection(title: "Hourly Forecast") {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 0) {
          ForEach(Array(shownHours.enumerated()), id: \.element.date) { index, hour in
            VStack(spacing: 8) {
              Group {
                if index == 0 {
                  Text("Now")
                } else if Calendar.current.component(.hour, from: hour.date) == 0 {
                  Text(verbatim: hour.date.monthDay).fontWeight(.semibold)
                } else {
                  Text(verbatim: hour.date.hour)
                }
              }
              .font(.footnote)
              .foregroundStyle(.secondary)
              WeatherSymbol(name: hour.symbolName)
                .font(.title2)
                .frame(height: 28)
              Text(
                verbatim: hour.precipitationChance.isShownAsPrecipitation
                  ? hour.precipitationChance.percent : " "
              )
              .font(.caption2.weight(.semibold))
              .foregroundStyle(.cyan)
              Text(verbatim: hour.temperature.degrees)
            }
            .frame(width: 56)
          }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
      }
    }
  }
}

/// Ten days; a row opens the day detail screen.
struct DaysCard: View {
  let days: [DayForecast]
  let level: SunnyLevel

  var body: some View {
    CardSection(title: "10-Day Forecast") {
      VStack(spacing: 0) {
        ForEach(Array(days.enumerated()), id: \.element.date) { index, day in
          NavigationLink(value: HomeRoute.day(index)) {
            DayRow(day: day, isToday: index == 0, isSunny: level.counts(day))
          }
          .buttonStyle(.plain)
          if index != days.count - 1 {
            Divider().padding(.leading, 66)
          }
        }
      }
      .padding(.vertical, 4)
    }
  }
}

struct DayRow: View {
  let day: DayForecast
  let isToday: Bool
  let isSunny: Bool

  var body: some View {
    HStack(spacing: 14) {
      VStack(spacing: 2) {
        WeatherSymbol(name: day.symbolName)
          .font(.title2)
          .frame(height: 28)
        if day.precipitationChance.isShownAsPrecipitation {
          Text(verbatim: day.precipitationChance.percent)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.cyan)
        }
      }
      .frame(width: 36)
      VStack(alignment: .leading, spacing: 2) {
        if isToday { Text("Today") } else { Text(verbatim: day.date.dayWithWeekday) }
        Text(verbatim: day.condition.localizedName)
          .font(.subheadline)
          .foregroundStyle(isSunny ? AnyShapeStyle(.orange) : AnyShapeStyle(.secondary))
      }
      Spacer(minLength: 8)
      HStack(spacing: 6) {
        Text(verbatim: day.highTemperature.degrees)
        Text(verbatim: day.lowTemperature.degrees).foregroundStyle(.secondary)
      }
      .font(.body.monospacedDigit())
      Image(systemName: "chevron.right")
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.tertiary)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .contentShape(Rectangle())
  }
}

/// Shown above the cached forecast when a refresh failed.
struct RefreshFailedBanner: View {
  let fetchedAt: Date
  let retry: () -> Void

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: "exclamationmark.icloud.fill")
        .font(.title2)
        .foregroundStyle(.red)
      VStack(alignment: .leading, spacing: 2) {
        Text("Couldn't update the weather")
          .font(.headline)
        Text("Showing the forecast from \(fetchedAt.fetchTime)")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      Spacer(minLength: 0)
      Button("Retry", action: retry)
        .buttonStyle(.glass)
        .controlSize(.small)
    }
    .padding(16)
    .background(
      Color(.secondarySystemGroupedBackground),
      in: RoundedRectangle(cornerRadius: 26, style: .continuous))
  }
}

/// Why there is no forecast to show.
struct NoDataCard: View {
  let failure: RegionForecast.Failure
  @Environment(\.openURL) private var openURL

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      switch failure {
      case .fetch:
        Label("Try again where you have a connection", systemImage: "wifi.exclamationmark")
          .font(.headline)
        Text(
          "The app couldn't connect to the internet or get the weather from Apple Weather. Wait a moment, or pull down on the screen to update."
        )
        .font(.subheadline)
        .foregroundStyle(.secondary)
      case .locationDenied:
        Label("Location access is off", systemImage: "location.slash.fill")
          .font(.headline)
        Text("Allow location access in Settings, or search for a region instead.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
        Button("Open Settings") {
          if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
        }
        .buttonStyle(.glass)
        .padding(.top, 4)
      case .locationUnavailable:
        Label("Couldn't find where you are", systemImage: "location.slash.fill")
          .font(.headline)
        Text("Try again in a moment, or search for a region instead.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
    }
    .padding(18)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      Color(.secondarySystemGroupedBackground),
      in: RoundedRectangle(cornerRadius: 26, style: .continuous))
  }
}

/// The cards in gray while the first forecast loads.
struct LoadingPlaceholder: View {
  var body: some View {
    Group {
      CardSection(title: "Hourly Forecast") {
        HStack(spacing: 0) {
          ForEach(0..<6, id: \.self) { _ in
            VStack(spacing: 8) {
              Text(verbatim: "00").font(.footnote)
              Image(systemName: "cloud.fill").font(.title2).frame(height: 28)
              Text(verbatim: "00%").font(.caption2)
              Text(verbatim: "00°")
            }
            .frame(width: 56)
          }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
      }
      CardSection(title: "10-Day Forecast") {
        VStack(spacing: 0) {
          ForEach(0..<6, id: \.self) { index in
            HStack(spacing: 14) {
              Image(systemName: "cloud.fill").font(.title2).frame(height: 28)
                .frame(width: 36)
              VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: "October 00 (Sat)")
                Text(verbatim: "Clear").font(.subheadline)
              }
              Spacer(minLength: 8)
              Text(verbatim: "00° 00°")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            if index != 5 {
              Divider().padding(.leading, 66)
            }
          }
        }
        .padding(.vertical, 4)
      }
    }
    .redacted(reason: .placeholder)
    .accessibilityHidden(true)
  }
}
