import SwiftUI

extension LinearGradient {
  static let nextSunnyDayBackground =
    LinearGradient(
      gradient: Gradient(colors: [
        Color(.nextSunnyDayBackgroundStart), Color(.nextSunnyDayBackgroundEnd),
      ]),
      startPoint: .top,
      endPoint: .bottom
    )

  static let noNextSunnyDayBackground =
    LinearGradient(
      gradient: Gradient(colors: [
        Color(.noNextSunnyDayBackgroundStart), Color(.noNextSunnyDayBackgroundEnd),
      ]),
      startPoint: .top,
      endPoint: .bottom
    )
}
