# 次いつ晴れる？ (Next Sunny Day)

[English](README.md)

<img src="docs/images/app-icon.png" width="160">

「次いつ晴れる？」は、次に晴れる日を「あした」「あと3日」のひと言で教えてくれるアプリです。

天気アプリのウィジェットには今日と明日の天気しか出ず、洗濯物をいつ外に干せるかがわかりにくかったため作りました。
ホーム画面、ロック画面、Apple Watch で、今日の天気と一緒に次の晴れを確かめられます。

iPhone、iPad、iPhone Duo、Apple Watch で使えて、日本語と英語に対応しています。

<a href="https://apps.apple.com/app/id1537055268"><img src="https://toolbox.marketingtools.apple.com/api/badges/download-on-the-app-store/black/ja-jp?size=250x83&amp;releaseDate=1603584000&h=dd86e3942b5c6abc5ce1781972220b17" alt="App Store からダウンロード" height="60"></a>

<img src="docs/release/screenshots/iphone/ja/01.jpg" width="260"><img src="docs/release/screenshots/iphone/ja/02.jpg" width="260"><img src="docs/release/screenshots/iphone/ja/03.jpg" width="260">

## 主な機能

- 次の晴れの日を大きく表示。天気、最高・最低気温、降水確率もわかる
- 24 時間先までと 10 日間の天気
- ホーム画面のすべてのサイズとロック画面のウィジェット
- 何を「晴れ」と数えるかを選べる（快晴だけ／晴れ／晴れ時々くもりまで／雨が降らなければOK）
- 洗濯日和も探せる。雨が降らず、7時から19時が晴れて乾いていて風の弱い日
- 地域は 3 つまで。現在地と、検索した市区町村
- 晴れが始まる前日に、決めた時刻にお知らせ
- Siri とショートカット：「次いつ晴れる？で次の晴れを調べて」
- Apple Watch のアプリと文字盤のコンプリケーション
- iPad、iPhone の横向き、iPhone Duo では予報の横に答えを表示
- 天気予報は Apple Weather のデータ。アカウントは不要

## スクリーンショット

### iPhone

<img src="docs/release/screenshots/iphone/ja/04.jpg" width="200"><img src="docs/release/screenshots/iphone/ja/05.jpg" width="200"><img src="docs/release/screenshots/iphone/ja/06.jpg" width="200"><img src="docs/release/screenshots/iphone/ja/07.jpg" width="200">

<img src="docs/release/screenshots/iphone/ja/08.jpg" width="200"><img src="docs/release/screenshots/iphone/ja/09.jpg" width="200"><img src="docs/release/screenshots/iphone/ja/10.jpg" width="200">

### iPad

<img src="docs/release/screenshots/ipad/ja/01.jpg" width="270"><img src="docs/release/screenshots/ipad/ja/02.jpg" width="270"><img src="docs/release/screenshots/ipad/ja/03.jpg" width="270">

<img src="docs/release/screenshots/ipad/ja/04.jpg" width="270"><img src="docs/release/screenshots/ipad/ja/05.jpg" width="270"><img src="docs/release/screenshots/ipad/ja/06.jpg" width="270">

<img src="docs/release/screenshots/ipad/ja/07.jpg" width="270"><img src="docs/release/screenshots/ipad/ja/08.jpg" width="270"><img src="docs/release/screenshots/ipad/ja/09.jpg" width="270">

### iPhone Duo

<img src="docs/release/screenshots/duo-inner/ja/01.jpg" width="270"><img src="docs/release/screenshots/duo-inner/ja/02.jpg" width="270">

<img src="docs/release/screenshots/duo-inner/ja/03.jpg" width="270"><img src="docs/release/screenshots/duo-inner/ja/04.jpg" width="270">

### Apple Watch

<img src="docs/release/screenshots/watch/ja/01.jpg" width="200"><img src="docs/release/screenshots/watch/ja/02.jpg" width="200"><img src="docs/release/screenshots/watch/ja/03.jpg" width="200">

## 開発

### 環境

| ツール | バージョン |
| --- | --- |
| Xcode | 27.1 |
| Swift | 6.4 (Swift 6 言語モード) |
| iOS / iPadOS | 26.0 以降 |
| watchOS | 26.0 以降 |

### 構成

| 項目 | 採用しているもの |
| --- | --- |
| UI | SwiftUI (Liquid Glass) |
| ウィジェット | WidgetKit (ホーム画面とロック画面) |
| Apple Watch | Watch アプリとコンプリケーション (WidgetKit)。設定は WatchConnectivity で iPhone から受け取る |
| 天気データ | WeatherKit |
| 場所の検索 | MapKit |
| 通知 | UserNotifications（ローカル通知） |
| Siri とショートカット | App Intents (App Shortcuts) |
| モジュール | モジュールごとのローカル Swift パッケージ |
| 状態 | Observation (environment に置く `@Observable` の状態ホルダー) |
| 並行処理 | Swift 6、Approachable Concurrency |
| ローカルの保存 | App Group の `UserDefaults` + JSON ファイル |
| テスト | Swift Testing |
| 依存ライブラリ | なし (Apple のフレームワークのみ) |
| ブランチ | `main`。変更は Pull Request で入れる |

アーキテクチャの決定とその理由は [`docs/architecture/decisions/`](docs/architecture/decisions/) にあります。

### 仕組み

アプリは、保存した地域と設定を `UserDefaults` に、地域ごとに取得した天気予報を JSON ファイルに保存します。保存先はどちらも、ウィジェットからも読める App Group のコンテナです。
予報は、アプリかウィジェットが直近の 4 時以降に取得していれば新しいものとみなします。アプリは、開いたときに予報が新しくなければ取得し、引っ張って更新したときにも取得します。
ウィジェットは保存された予報を表示し、1 日に 1 回、4 時過ぎに更新します。保存された予報が新しくなければ、ウィジェット自身が WeatherKit から取得します。
Apple Watch は地域と設定を iPhone から受け取り、予報は同じ規則で Watch 自身が取得します。
詳しくは [`docs/architecture/weather-fetch-flow.md`](docs/architecture/weather-fetch-flow.md) を見てください。

### ディレクトリ構成

```
NextSunnyDay/               # アプリ
├── App/                    # エントリポイント、AppFeatures、PreviewHost
├── SharedState/            # 画面間で共有する @Observable の状態ホルダー
├── Home/  DayDetail/  Onboarding/  Region/  Settings/
├── Components/
├── Resources/              # String Catalogs (.xcstrings)
└── Assets.xcassets
NextSunnyDayWidget/         # ウィジェット拡張。Watch のコンプリケーションにも組み込む
NextSunnyDayWatch/          # Apple Watch アプリ
NextSunnyDayWatchWidget/    # Watch のコンプリケーション: iPhone のウィジェットと違う部分
NextSunnyDayTests/          # アプリ層のテスト
Packages/
├── Core/                   # Weather, Location, PlaceSearch, Notifications, AppGroup, WatchSync
└── Features/               # Region, Forecast, SunnyDay, Notice, Units
Tools/ImportCheck/          # import がすべて宣言済みの依存かを確かめる CI 用ツール
docs/                       # デザイン仕様、アーキテクチャの資料と ADR
```

## セットアップ

### リポジトリを clone する

```sh
$ git clone git@github.com:naipaka/NextSunnyDay-iOS.git
$ cd NextSunnyDay-iOS
```

### 天気データ

天気予報は [WeatherKit](https://developer.apple.com/weatherkit/) から取得します。ビルドに API キーは要りません。
実際の予報を取得するには、Certificates, Identifiers & Profiles で、アプリ、ウィジェット、Watch アプリ、Watch のコンプリケーションの App ID に WeatherKit の capability を、チームに WeatherKit の App Service を有効にしておく必要があります。自分のチームでビルドする場合は、バンドル ID を変えて、自分の App ID で有効にしてください。

### フォーマット

コードのフォーマットと lint には、Xcode 同梱の `swift-format` を `.swift-format` の設定で使います。CI では lint の警告があると失敗します。

```sh
$ xcrun swift-format format -i -r -p NextSunnyDay NextSunnyDayWidget NextSunnyDayWatch NextSunnyDayWatchWidget NextSunnyDayTests Packages Tools
$ xcrun swift-format lint --strict -r -p NextSunnyDay NextSunnyDayWidget NextSunnyDayWatch NextSunnyDayWatchWidget NextSunnyDayTests Packages Tools
```

### ビルドとテスト

`NextSunnyDay.xcodeproj` を Xcode で開き、アプリをビルドして実行してください。アプリのテストは `NextSunnyDay` スキームで実行します。各パッケージは Mac 上で単体でもテストできます。

```sh
$ for p in Packages/Core/* Packages/Features/* Tools/ImportCheck; do (cd "$p" && swift test); done
```
