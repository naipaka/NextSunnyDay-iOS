//
//  DailyWeatherForecastEntity.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/09.
//

import Foundation
import RealmSwift

// MARK: - DailyWeatherForecastEntity
class DailyWeatherForecastEntity: Object, Identifiable {
    @objc dynamic var id: Int = 0
    @objc dynamic var cityName: String = ""
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lon: Double = 0.0
    var daily = List<Daily>()

    override static func primaryKey() -> String? {
        "id"
    }
}

// MARK: - Daily
class Daily: Object, Identifiable {
    @objc dynamic var date: Int = 0
    @objc dynamic var temp: Temp?
    @objc dynamic var humidity: Int = 0
    @objc dynamic var pop: Double = 0.0
    @objc dynamic var rain: Double = 0.0
    @objc dynamic var snow: Double = 0.0
    @objc dynamic var uvi: Double = 0.0
    var weather = List<Weather>()
}

// MARK: - Temp
class Temp: Object, Identifiable {
    @objc dynamic var day: Double = 0.0
    @objc dynamic var min: Double = 0.0
    @objc dynamic var max: Double = 0.0
    @objc dynamic var night: Double = 0.0
    @objc dynamic var eve: Double = 0.0
    @objc dynamic var morn: Double = 0.0
}

// MARK: - Weather
class Weather: Object, Identifiable {
    @objc dynamic var id: Int = 0
    @objc dynamic var main: String = ""
    @objc dynamic var weatherDescription: String = ""
    @objc dynamic var icon: String = ""
}

// MARK: - CRUD
extension DailyWeatherForecastEntity {
    private static var realm: Realm {
        var config = Realm.Configuration()
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.naipaka.NextSunnyDay")!
        config.fileURL = url.appendingPathComponent("db.realm")
        let realm = try! Realm(configuration: config)
        return realm
    }

    static func all() -> Results<DailyWeatherForecastEntity> {
        realm.objects(self)
    }

    static func create(with weeklyWeather: DailyWeatherForecastEntity) {
        try! realm.write {
            realm.add(weeklyWeather)
        }
    }

    static func update(with weeklyWeather: DailyWeatherForecastEntity) {
        try! realm.write {
            realm.create(DailyWeatherForecastEntity.self, value: weeklyWeather, update: .all)
        }
    }
}
