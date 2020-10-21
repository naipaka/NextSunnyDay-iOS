# NextSunnyDay-iOS

「次いつ晴れる？」

次いつ晴れるのかが一目でわかるアプリ

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

Comming Soon...

## AppStore

Comming Soon...
