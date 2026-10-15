# App Store metadata

The App Store listing in English and Japanese for the 2.0 release (#100), with What's New, the notes for App Review and the answers to App Store Connect's questionnaires.

Limits in App Store Connect: name and subtitle 30 characters each, promotional text 170, keywords 100 (comma-separated, no spaces needed after commas), description 4,000. The Japanese keywords are kept under 100 bytes as well, in case the field counts UTF-8 bytes.

## English (U.S.)

**Name:**

```text
Next Sunny Day
```

**Subtitle:**

```text
When will it be sunny again?
```

**Promotional text:**

```text
See at a glance when the next sunny day is: on your Home Screen and Lock Screen, on Apple Watch, or ask Siri.
```

**Keywords:**

```text
weather,forecast,sunny,sunshine,clear sky,laundry,widget,lock screen,10-day,rain,outdoor,dry,watch
```

**Description:**

```text
Next Sunny Day tells you when the sun comes out next.

Most weather widgets show only today and tomorrow. If you want to hang the laundry outside, plan a walk or wash the car, you have to open a weather app and scan the whole week. Next Sunny Day answers that question in one word, Tomorrow or In 3 days, and shows today's weather beside it.

FEATURES

• The next sunny day, big and clear, with its weather, high and low and chance of rain
• The next 24 hours and the next 10 days
• Widgets for the Home Screen in every size and for the Lock Screen, so you don't even need to open the app
• Choose what counts as sunny: clear only, sunny, up to partly cloudy, or any day without rain
• Or look for a laundry day: no rain, sunny, dry and calm from 7:00 to 19:00
• Up to three regions: your current location and any city you search for
• A notification the day before a sunny spell starts, at the time you choose
• Ask Siri: "Check Next Sunny Day"
• On Apple Watch, in the app and as complications on your watch face
• On iPad, on iPhone in landscape and on iPhone Duo, the answer sits beside the forecast
• Temperatures in your own units, in English and Japanese

The forecast comes from Apple Weather and is updated once a day in the early morning. Pull down in the app to update it yourself.
```

## Japanese

**Name:**

```text
次いつ晴れる？
```

**Subtitle:**

```text
次の晴れの日がひと目でわかる
```

**Promotional text:**

```text
次に晴れる日を、ホーム画面とロック画面のウィジェットや Apple Watch でひと目で確かめられます。Siri に聞くこともできます。
```

**Keywords:**

```text
天気,天気予報,晴れ,快晴,洗濯物,ウィジェット,降水確率,週間天気,通知
```

**Description:**

```text
「次いつ晴れる？」は、次に晴れる日がひと目でわかるアプリです。

天気アプリのウィジェットに出るのは、たいてい今日と明日の天気だけ。洗濯物を外に干したい日や出かけたい日を探すには、天気アプリを開いて 1 週間分を見比べる必要がありました。このアプリなら「あした」「あと3日」と、ひと言で答えます。今日の天気もその横に出ます。

◆ 主な機能

・次の晴れの日を大きく表示。天気、最高・最低気温、降水確率もわかります
・24 時間先までと 10 日間の天気
・ホーム画面のすべてのサイズとロック画面のウィジェット。アプリを開かなくても確かめられます
・何を「晴れ」と数えるかを選べます（快晴だけ／晴れ／晴れ時々くもりまで／雨が降らなければOK）
・洗濯日和も探せます。雨が降らず、7時から19時が晴れて乾いていて風の弱い日です
・地域は 3 つまで。現在地と、検索した市区町村
・晴れが始まる前日に、決めた時刻にお知らせ
・Siri に「次いつ晴れる？で次の晴れを調べて」
・Apple Watch のアプリと文字盤のコンプリケーション
・iPad、iPhone の横向き、iPhone Duo では予報の横に答えを表示
・日本語と英語に対応

天気予報は Apple Weather のデータを使っています。予報は毎日早朝に新しくなり、アプリの画面を下に引っぱると手動でも更新できます。
```

## What's New

English:

```text
Next Sunny Day is back, rebuilt from the ground up.

• Forecasts from Apple Weather
• A new design with Liquid Glass
• Widgets in every Home Screen size and on the Lock Screen
• Up to three regions
• A notification the day before a sunny spell
• The laundry-day level
• Siri and Shortcuts
• Apple Watch app and complications
• iPad, iPhone in landscape and iPhone Duo
• English

The region from version 1 isn't carried over: choose it again after updating.
```

Japanese:

```text
「次いつ晴れる？」が、まるごと作り直して帰ってきました。

・天気予報は Apple Weather のデータに
・Liquid Glass の新しいデザイン
・ホーム画面のすべてのサイズとロック画面のウィジェット
・地域は 3 つまで
・晴れの前日にお知らせ
・洗濯日和の基準
・Siri とショートカット
・Apple Watch のアプリとコンプリケーション
・iPad、iPhone の横向き、iPhone Duo
・英語に対応

バージョン 1 で選んでいた地域は引き継がれません。アップデート後にもう一度選んでください。
```

## What's New in 2.0.1

English:

```text
• Fixed widgets staying blank and their region not being selectable
• Fixed the weather being fetched again when switching to a region that already had it
```

Japanese:

```text
・ウィジェットが空白のまま表示されず、地域も選べない問題を修正しました
・地域を切り替えたとき、取得済みの天気をもう一度取得していた問題を修正しました
```

## Screenshots

In `screenshots/<device>/<language>/`, numbered in upload order. Each is a composition: the screen captured in the simulator, the part that makes the point enlarged over it, and a headline. They were captured with the recorded forecasts written into the app's cache, the clock moved to the morning so the hours start at 9:41, and the status bar at 9:41 with full bars. The notifications on the lock screens were posted to the simulator with the app's own wording.

| Device | Folder | Size | Images |
| --- | --- | --- | --- |
| iPhone | `iphone` | 1206 × 2622 | 10 |
| iPad 13" | `ipad` | 2064 × 2752 | 9 |
| iPhone Duo outer display | `duo-outer` | 1398 × 2034 | 6 |
| iPhone Duo inner display | `duo-inner` | 2007 × 2853 | 4 (Japanese), 5 (English) |
| Apple Watch | `watch` | 416 × 496 | 3, without headlines |

iPhone: 1–3 are one picture under 「「次いつ晴れる？」がすぐわかる」 / "The next sunny day in one word" (the app, the Home Screen, the Lock Screen), then widget sizes, what counts as sunny, the laundry day, hourly and 10-day forecasts in Dark Mode, the notification the day before, up to three regions, Apple Watch.

iPad: 1–3 as on iPhone in landscape, with the extra large widget, then what counts as sunny, the laundry day, Dark Mode, the notification, regions, and how long the sunny spell lasts.

iPhone Duo: the outer display has the answer, what counts as sunny, the laundry day, Dark Mode, the notification and regions; the inner display the sunny day's details under the answer, the laundry day, Dark Mode, another region and, in English, the notification.

Apple Watch: the answer, the next days, the watch face.

## Notes for App Review

```text
No account or sign-in is needed. The forecast comes from WeatherKit. The Apple Weather mark and the link to its data sources and legal information are at the bottom of Home and of a day's detail, in Settings > About Weather Data, and in the medium and larger widgets.

Location is optional: on the first screen, choose Use Current Location or search for a city. Notifications are off until they are turned on in Settings > Notifications. Where a law requires it, the app asks for the age range with the Declared Age Range API; it shows the same content at every age.
```

## App Privacy

Data Not Collected. App Store Connect defines collecting as sending data off the device so that the developer or a partner can access it longer than the request needs. The app has no server: the coordinate goes to WeatherKit and the search text to MapKit only to answer the request, and data collected by Apple is not the developer's to disclose. No tracking. Each bundle's `PrivacyInfo.xcprivacy` declares the App Group's `UserDefaults` (`1C8F.1`).

## Age rating

4+. The answers to the questionnaire, by the definitions in [Age ratings values and definitions](https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions/):

- **In-app controls:** no parental controls. No age assurance: the app asks for the age range where a law requires it, but shows the same content at every age, so it doesn't confirm an age to unlock anything.
- **Capabilities:** no unrestricted web access (the legal link opens in Safari, not in the app), no user-generated content, no social media, no messaging or chat, no advertising.
- **Mature themes, medical or wellness, sexuality or nudity, violence, chance-based activities:** none. The forecast is weather data, not health advice.

## Before submitting

- The English (U.S.) localization is added to the app record, with the name "Next Sunny Day" (App Store names are unique across the store).
- Release manually after approval, so that the `v2.0.0` tag and the GitHub release go out the same day.
