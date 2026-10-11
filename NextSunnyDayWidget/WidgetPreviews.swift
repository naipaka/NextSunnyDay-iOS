import SwiftUI
import WidgetKit

#Preview("Small", as: .systemSmall) {
  NextSunnyDayWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}

#Preview("Medium", as: .systemMedium) {
  NextSunnyDayWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}

#Preview("Large", as: .systemLarge) {
  NextSunnyDayWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}

#Preview("Inline", as: .accessoryInline) {
  NextSunnyDayWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}

#Preview("Circular", as: .accessoryCircular) {
  NextSunnyDayWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}

#Preview("Rectangular", as: .accessoryRectangular) {
  NextSunnyDayWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}

#Preview("Extra Large", as: .systemExtraLarge) {
  NextSunnyDayWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}

@available(iOS 27.0, *)
#Preview("Extra Large Portrait", as: .systemExtraLargePortrait) {
  NextSunnyDayWidget()
} timeline: {
  SunnyEntry.sunny
  SunnyEntry.laundry
  SunnyEntry.noneInRange
  SunnyEntry.noData
  SunnyEntry.noRegion
}
