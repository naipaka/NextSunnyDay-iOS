//
//  Measurement+Extension.swift
//  NextSunnyDay
//

import Foundation

extension Measurement<UnitTemperature> {
  /// The temperature in whole degrees Celsius, e.g. `12℃`.
  var celsiusText: String {
    "\(Int(converted(to: .celsius).value.rounded()))℃"
  }
}
