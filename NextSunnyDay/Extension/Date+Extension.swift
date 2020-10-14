//
//  Date+Extension.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/14.
//

import Foundation

extension Date {
    /*
     yy     西暦年  2桁             2012年 -> 12
     yyyy   西暦年  4桁             2012年 -> 2012
     M      月                     8月 -> 8
     MM     月(ゼロ埋め)             8月 -> 08
     d      月に対する日             3日 -> 3
     dd     月に対する日(ゼロ埋め)     3日 -> 03
     e      曜日                   2011年8月30日 -> 3
     E      曜日(漢字)              2011年8月30日 -> 火
     a      午前/午後               13:00 -> 午後
     h      時(12時間制)            13時 -> 1
     hh     時(12時間制ゼロ埋め)      13時 -> 01
     H      時(24時間制             13時 -> 13
     HH     時(24時間制ゼロ埋め)      13時 -> 13
     m      分                     3分 -> 3
     mm     分(ゼロ埋め)             3分 -> 03
     s      秒                     3秒 -> 3
     ss     秒(ゼロ埋め)             3秒 -> 03
     S      ミリ秒                 3ミリ秒 -> 3
     SSS    ミリ秒(ゼロ埋め)         3ミリ秒 -> 003
     */
    /// Date Format (ja_JP)
    /// - Parameter text: dateFormat
    /// - Returns:Formated Text
    func format(text: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = text
        return dateFormatter.string(from: self)
    }
}
