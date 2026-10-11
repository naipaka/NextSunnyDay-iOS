import SwiftUI
import Weather

/// Hours as columns of time, symbol, precipitation chance and temperature, over the temperature
/// as an orange line with a light area below. The columns share the width they get, down to a
/// minimum; past that the chart scrolls sideways.
struct TemperatureChart: View {
  let hours: [HourForecast]
  /// Labels the first hour 「今」 and the first hour of a day with its date, as Home's strip does.
  var startsNow = false

  @ScaledMetric private var minimumCellWidth: CGFloat = 30
  @ScaledMetric private var symbolHeight: CGFloat = 24
  @Environment(TemperatureUnitSelection.self) private var temperatureUnitSelection

  private var temperatureUnit: UnitTemperature { temperatureUnitSelection.unit }

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      VStack(spacing: 8) {
        HStack(spacing: 0) {
          ForEach(Array(hours.enumerated()), id: \.element.date) { index, hour in
            column(hour, index: index)
              .frame(minWidth: 0, maxWidth: .infinity)
          }
        }
        TemperatureCurve(values: hours.map { $0.temperature.converted(to: .celsius).value })
          .frame(height: 56)
          .accessibilityHidden(true)
      }
      // The scroll view's width, not a measured one: feeding a measured width back into the
      // layout made it alternate by half a point forever when the window resized.
      .containerRelativeFrame(.horizontal) { width, _ in
        max(width, minimumCellWidth * CGFloat(hours.count))
      }
    }
    .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
  }

  private func column(_ hour: HourForecast, index: Int) -> some View {
    VStack(spacing: 6) {
      label(hour, index: index)
        .font(.caption)
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
      WeatherSymbol(name: hour.symbolName)
        .font(.title3)
        .frame(height: symbolHeight)
      Text(
        verbatim: hour.precipitationChance.isShownAsPrecipitation
          ? hour.precipitationChance.percent : " "
      )
      .font(.caption2.weight(.semibold))
      .foregroundStyle(.cyan)
      .lineLimit(1)
      .minimumScaleFactor(0.7)
      Text(verbatim: hour.temperature.degrees(in: temperatureUnit))
        .font(.subheadline)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(Text(verbatim: spoken(hour, index: index)))
  }

  @ViewBuilder private func label(_ hour: HourForecast, index: Int) -> some View {
    if startsNow && index == 0 {
      Text("Now")
    } else if startsNow && Calendar.current.component(.hour, from: hour.date) == 0 {
      Text(verbatim: hour.date.monthDay).fontWeight(.semibold).foregroundStyle(.primary)
    } else {
      Text(verbatim: hour.date.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted))))
    }
  }

  /// What VoiceOver says for a column, with the condition the symbol shows.
  private func spoken(_ hour: HourForecast, index: Int) -> String {
    let time = startsNow && index == 0 ? String(localized: "Now") : hour.date.hour
    var parts = [time, hour.condition.localizedName]
    if hour.precipitationChance.isShownAsPrecipitation {
      parts.append(String(localized: "Chance of rain \(hour.precipitationChance.percent)"))
    }
    parts.append(hour.temperature.degrees(in: temperatureUnit))
    return parts.joined(separator: ", ")
  }
}

/// The temperature line through the middle of each column, smoothed, with a light area below.
struct TemperatureCurve: View {
  let values: [Double]
  var color: Color = .orange

  var body: some View {
    GeometryReader { proxy in
      let line = path(in: proxy.size)
      ZStack {
        area(line, size: proxy.size).fill(color.opacity(0.14))
        line.stroke(color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
      }
    }
  }

  private func points(in size: CGSize) -> [CGPoint] {
    guard let low = values.min(), let high = values.max(), !values.isEmpty else { return [] }
    let span = max(high - low, 1)
    let step = size.width / CGFloat(values.count)
    return values.enumerated().map { index, value in
      CGPoint(
        x: step * (CGFloat(index) + 0.5),
        y: size.height - 6 - (value - low) / span * (size.height - 12))
    }
  }

  /// A Catmull-Rom curve through the points, as cubic Béziers.
  private func path(in size: CGSize) -> Path {
    let points = points(in: size)
    var path = Path()
    guard let first = points.first else { return path }
    path.move(to: first)
    for index in points.indices.dropLast() {
      let p0 = points[max(index - 1, 0)]
      let p1 = points[index]
      let p2 = points[index + 1]
      let p3 = points[min(index + 2, points.count - 1)]
      path.addCurve(
        to: p2,
        control1: CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6),
        control2: CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6))
    }
    return path
  }

  private func area(_ line: Path, size: CGSize) -> Path {
    let points = points(in: size)
    guard let first = points.first, let last = points.last else { return Path() }
    var area = line
    area.addLine(to: CGPoint(x: last.x, y: size.height))
    area.addLine(to: CGPoint(x: first.x, y: size.height))
    area.closeSubpath()
    return area
  }
}
