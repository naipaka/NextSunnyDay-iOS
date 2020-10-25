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
            gradient: Gradient(colors: [Color(R.color.nextSunnyDayBackgroundStart() ?? .orange), Color(R.color.nextSunnyDayBackgroundEnd() ?? .orange)]),
            startPoint: .top,
            endPoint: .bottom
        )

    static let noNextSunnyDayBackground =
        LinearGradient(
            gradient: Gradient(colors: [Color(R.color.noNextSunnyDayBackgroundStart() ?? .gray), Color(R.color.noNextSunnyDayBackgroundEnd() ?? .gray)]),
            startPoint: .top,
            endPoint: .bottom
        )
}
