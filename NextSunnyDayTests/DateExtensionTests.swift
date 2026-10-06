//
//  DateExtensionTests.swift
//  NextSunnyDayTests
//

import Foundation
@testable import NextSunnyDay
import Testing

struct DateExtensionTests {
    // 2020-10-14 (Wed) 13:05:09 in the current time zone, which `format(text:)` also uses.
    private let date = Calendar.current.date(
        from: DateComponents(year: 2020, month: 10, day: 14, hour: 13, minute: 5, second: 9)
    )!

    @Test(arguments: [
        ("yyyy/MM/dd", "2020/10/14"),
        ("M/d", "10/14"),
        ("E", "水"),
        ("a h:mm:ss", "午後 1:05:09"),
        ("HH:mm", "13:05"),
    ])
    func formatsInJapanese(format: String, expected: String) {
        #expect(date.format(text: format) == expected)
    }
}
