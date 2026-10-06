//
//  Date+Extension.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/14.
//

import Foundation

extension Date {
  /// Formats the date in the ja_JP locale.
  /// - Parameter text: A date format pattern (Unicode TR35), e.g. `M/d (EEE)`.
  /// - Returns: The formatted date.
  func format(text: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ja_JP")
    dateFormatter.dateFormat = text
    return dateFormatter.string(from: self)
  }
}
