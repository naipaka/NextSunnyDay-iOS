//
//  WeatherError.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/01.
//

import Foundation

enum WeatherError: Error {
  case parsing(description: String)
  case network(description: String)
}
