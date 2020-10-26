# NextSunnyDay-iOS

## 次いつ晴れる？

<img src="https://user-images.githubusercontent.com/45661924/97105071-d28d2580-16fb-11eb-8f8d-7ec79940db41.png" width="300">

<img src="https://user-images.githubusercontent.com/45661924/97104876-7544a480-16fa-11eb-9bad-e1334d5ab2f8.png" height="300">

次いつ晴れるのかが一目でわかるアプリです。

<a href="https://apps.apple.com/us/app/%E6%AC%A1%E3%81%84%E3%81%A4%E6%99%B4%E3%82%8C%E3%82%8B/id1537055268?itsct=apps_box&amp;itscg=30200" style="display: inline-block; overflow: hidden; border-radius: 13px; width: 250px; height: 83px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-US?size=250x83&amp;releaseDate=1603584000&h=dd86e3942b5c6abc5ce1781972220b17" alt="Download on the App Store" style="border-radius: 13px; width: 250px; height: 83px;"></a>

## Development

### Environment

| Tool  | Version          |
| ----- | ---------------- |
| Xcode | 12.0.1 (12A7300) |
| Swift | 5.3              |
| Mint  | 0.14.2           |

### Configuration

| Configuration     | Model        |
| ----------------- | ------------ |
| UI implementation | Swift UI     |
| Architecture      | MVVM+Combine |
| Branching model   | Git-flow     |

### Directory Structure

```
NextSunnyDay/
├── NextSunnyDayApp.swift
├── API/
│   └── AccessTokens.swift
│   └── OpenWeatherAPI/
│   └── LocalSearch/
├── Model/
├── View/
├── ViewModel/
├── Protocol/
├── Extension/
├── UIViewRepresentable/
├── Script/
├── Resourece/
│   └── strings/
├── Assets.xcassets
├── info.plist
└── Preview Content/
    └── Preview Assets.xcassets
```

## Set up

### Clone the project

```sh
$ git clone git@github.com:naipaka/NextSunnyDay-iOS.git
$ cd NextSunnyDay
```

### API key

このアプリでは、OpenWeather 社の API を利用しています。

動作を確認する際は下記サイトで API key を取得してください。

[How to start to work with Openweather API - OpenWeatherMap](https://openweathermap.org/appid)

API key が取得できたら、下記コマンドをルートディレクトリで実行してください。

```sh
$ echo "let OPEN_WEATHER_API_KEY = \"{取得したAPI key}\"" > ./NextSunnyDay/API/AccessTokens.swift
```

### Mint

[Mint](https://github.com/yonaskolb/Mint)をインストールしていない方は事前にインストールしてください。

```sh
$ mint bootstrap
```

### Build

Build & Run !!

## Screenshots

| -              | Light                                                                                                                        | Dark                                                                                                                         |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Widget         | <img src="https://user-images.githubusercontent.com/45661924/97104984-4f6bcf80-16fb-11eb-8e4f-13f0b694cd4b.png" width="300"> | <img src="https://user-images.githubusercontent.com/45661924/97105017-8e018a00-16fb-11eb-92ad-20fd0c67c0e0.png" width="300"> |
| Home           | <img src="https://user-images.githubusercontent.com/45661924/97104990-54c91a00-16fb-11eb-9408-40ac76eb52ea.png" width="300"> | <img src="https://user-images.githubusercontent.com/45661924/97105024-98bc1f00-16fb-11eb-8149-fbffd415dd3e.png" width="300"> |
| Setting        | <img src="https://user-images.githubusercontent.com/45661924/97104994-585ca100-16fb-11eb-9bcb-c57bc9009f55.png" width="300"> | <img src="https://user-images.githubusercontent.com/45661924/97105027-9c4fa600-16fb-11eb-9d8c-41614202eddb.png" width="300"> |
| Region Search  | <img src="https://user-images.githubusercontent.com/45661924/97105000-66122680-16fb-11eb-9286-2bf512212082.png" width="300"> | <img src="https://user-images.githubusercontent.com/45661924/97105031-9fe32d00-16fb-11eb-841f-8b9753442253.png" width="300"> |
| Search results | <img src="https://user-images.githubusercontent.com/45661924/97105005-6d393480-16fb-11eb-8be8-06fbf7204ec0.png" width="300"> | <img src="https://user-images.githubusercontent.com/45661924/97105039-a671a480-16fb-11eb-873b-77fec5736546.png" width="300"> |
| About weather  | <img src="https://user-images.githubusercontent.com/45661924/97105009-7fb36e00-16fb-11eb-849e-a4b6c5bffdb8.png" width="300"> | <img src="https://user-images.githubusercontent.com/45661924/97105042-aa052b80-16fb-11eb-9feb-f18031116f02.png" width="300"> |
