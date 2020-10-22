//
//  LinearGradient+Extension.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/22.
//

import SwiftUI

extension LinearGradient {
    static let nextSunnyDayBackground =
        LinearGradient(
            gradient: Gradient(colors: [Color(R.color.nextSunnyDayStartBackgroudColor() ?? .orange), Color(R.color.nextSunnyDayEndBackgroundColor() ?? .orange)]),
            startPoint: .top,
            endPoint: .bottom
        )

    static let noNextSunnyDayBackground =
        LinearGradient(
            gradient: Gradient(colors: [Color(R.color.noSunnyDayStartBackgroundColor() ?? .gray), Color(R.color.noSunnyDayEndBackgroundColor() ?? .gray)]),
            startPoint: .top,
            endPoint: .bottom
        )
}
