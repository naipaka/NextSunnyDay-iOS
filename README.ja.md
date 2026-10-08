# 次いつ晴れる？ (Next Sunny Day)

[English](README.md)

<img src="https://user-images.githubusercontent.com/45661924/97105071-d28d2580-16fb-11eb-8f8d-7ec79940db41.png" width="300">

<img src="docs/images/widget.jpg" width="600">

次に晴れる日を、ホーム画面のウィジェットで確かめられる iOS アプリです。
天気アプリのウィジェットには今日と明日の天気しか出ず、洗濯物をいつ外に干せるかがわかりにくかったため作りました。
アプリでは、次の晴れの日に加えて、24 時間先までと 10 日間の天気を見られます。何を「晴れ」と数えるかも選べます。

<a href="https://apps.apple.com/app/id1537055268" style="display: inline-block; overflow: hidden; border-radius: 13px; width: 250px; height: 83px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-US?size=250x83&amp;releaseDate=1603584000&h=dd86e3942b5c6abc5ce1781972220b17" alt="Download on the App Store" style="border-radius: 13px; width: 250px; height: 83px;"></a>

## 開発

### 環境

| ツール | バージョン       |
| ------ | ---------------- |
| Xcode  | 26.4.1           |
| Swift  | 6.3 (Swift 5 モード) |

### 構成

| 項目               | 採用しているもの |
| ------------------ | ---------------- |
| UI                 | SwiftUI          |
| ウィジェット       | WidgetKit        |
| アーキテクチャ     | MVVM+Combine     |
| ローカルの保存     | UserDefaults + JSON ファイル |
| ブランチの運用     | Git-flow         |

### 仕組み

アプリは、選んだ場所を `UserDefaults` に、取得した天気予報を JSON ファイルに保存します。保存先はどちらも、ウィジェットからも読める App Group のコンテナです。サードパーティのライブラリは使っていません。
ウィジェットは保存された予報を表示し、5 時間ごとに更新します。保存された予報が古くなると、ウィジェット自身が WeatherKit から新しい予報を取得します。
場所の検索には、MapKit の `MKLocalSearchCompleter` を使っています。

### ディレクトリ構成

```
NextSunnyDay/
├── NextSunnyDayApp.swift
├── API/
│   ├── Weather/          # WeatherKit
│   └── LocalSearch/
├── Model/
├── Storage/            # 設定と予報のキャッシュ
├── View/
├── ViewModel/
├── Protocol/
├── Extension/
├── UIViewRepresentable/
├── Resources/            # String Catalogs (.xcstrings)
├── Assets.xcassets
├── Info.plist
└── Preview Content/
    └── Preview Assets.xcassets
NextSunnyDayWidget/
└── NextSunnyDayWidget.swift
```

## セットアップ

### リポジトリを clone する

```sh
$ git clone git@github.com:naipaka/NextSunnyDay-iOS.git
$ cd NextSunnyDay-iOS
```

### 天気データ

天気予報は [WeatherKit](https://developer.apple.com/weatherkit/) から取得します。ビルドに API キーは要りません。
実際の予報を取得するには、Certificates, Identifiers & Profiles で、アプリとウィジェットの App ID に WeatherKit の capability を、チームに WeatherKit の App Service を有効にしておく必要があります。自分のチームでビルドする場合は、バンドル ID を変えて、自分の App ID で有効にしてください。

### フォーマット

コードのフォーマットと lint には、Xcode 同梱の `swift-format` を `.swift-format` の設定で使います。CI では lint の警告があると失敗します。

```sh
$ xcrun swift-format format -i -r -p NextSunnyDay NextSunnyDayWidget NextSunnyDayTests
$ xcrun swift-format lint --strict -r -p NextSunnyDay NextSunnyDayWidget NextSunnyDayTests
```

### ビルド

`NextSunnyDay.xcodeproj` を Xcode で開き、アプリをビルドして実行してください。

## スクリーンショット

| 画面 | Light | Dark |
| --- | --- | --- |
| ホーム | <img src="docs/images/home-light.jpg" width="300"> | <img src="docs/images/home-dark.jpg" width="300"> |
| 日別詳細 | <img src="docs/images/day-light.jpg" width="300"> | <img src="docs/images/day-dark.jpg" width="300"> |
| 設定 | <img src="docs/images/settings-light.jpg" width="300"> | <img src="docs/images/settings-dark.jpg" width="300"> |
| 地域検索 | <img src="docs/images/region-light.jpg" width="300"> | <img src="docs/images/region-dark.jpg" width="300"> |
| 天気データについて | <img src="docs/images/about-light.jpg" width="300"> | <img src="docs/images/about-dark.jpg" width="300"> |
