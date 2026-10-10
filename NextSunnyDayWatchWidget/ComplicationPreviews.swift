import SwiftUI
import WidgetKit

#Preview("Circular", as: .accessoryCircular) {
  NextSunnyDayWatchWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}

#Preview("Corner", as: .accessoryCorner) {
  NextSunnyDayWatchWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}

#Preview("Rectangular", as: .accessoryRectangular) {
  NextSunnyDayWatchWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}

#Preview("Inline", as: .accessoryInline) {
  NextSunnyDayWatchWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}
