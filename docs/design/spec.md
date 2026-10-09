# NextSunnyDay 2.0 design spec

Approved design for the 2.0 revival (#93). The implementation tasks #94–#98 build from this document. The screenshots were taken on an iPhone 17 (iOS 26.4) simulator, so they show real SF Symbols, Liquid Glass and system colors. The screenshots and the values in this document are the source of truth. Each image puts light on the left and dark on the right. Sample data: Minato, Tokyo, on Wed 7 Oct, with the next sunny day on Sat 10 Oct.

## Decisions

| Topic | Decision |
| --- | --- |
| Regions | A single region. The user picks it by search, or chooses "use current location" (Core Location). No list of saved regions. |
| Sunny definition | A user setting with four levels; the default matches v1. See [Sunny levels](#sunny-levels). |
| Hourly forecast | Home shows the next 24 hours as a horizontal strip, so the strip stays useful in the evening. Each day's hours are in the day detail screen, which opens from a row in the 10-day list. |
| Precipitation chance | Shown under the weather symbol in hourly cells and daily rows when it is 20 % or more. |
| Manual refresh | Pull to refresh on Home. |
| Widgets | Home Screen small, medium and large. Lock Screen circular, rectangular and inline. No Control Center control. |
| Visual direction | Close to iOS 26 standard apps: system colors and materials, SF Symbols and grouped cards. System orange is the single accent and carries the "next sunny day" header. |
| Japanese tone | Friendly and casual, matching the app name 次いつ晴れる？ (e.g. 「次の晴れは あと3日」, 「まだ先かも」). |
| App icon | Keep the v1 sun lion and split it into three Icon Composer layers. The dark look inverts the light one. See [App icon](#app-icon). |

## Visual language

- **System colors only.** Backgrounds use `systemGroupedBackground` and `secondarySystemGroupedBackground`; text uses `label`, `secondaryLabel` and `tertiaryLabel`. Don't hard-code hex values in code. The one accent is `Color.orange`, and it stays the system orange in dark mode (don't darken it). With Increase Contrast on, the header colors use their light variants in both appearances: the dark variants get lighter and drop the white header text to about 2:1, the light ones get darker and reach 4.5:1.
- **Weather symbols** are SF Symbols with the palette rendering mode. Clouds use `systemGray2` in light and white in dark; the sun and moon are yellow; rain drops and the precipitation chance are cyan. Symbols used: `sun.max.fill` (clear), `sun.min.fill` (mostly clear), `cloud.sun.fill` (partly cloudy), `cloud.fill`, `cloud.rain.fill`, `cloud.heavyrain.fill`, `cloud.drizzle.fill`, and the night variants `cloud.moon.fill` and `moon.stars.fill` in hourly cells.
- **Type.** Use system text styles so Dynamic Type works. The big "days until" number is the only display-size text (72 pt bold, scaled down to fit). Section headers are `subheadline` in `secondaryLabel`, regular weight. Rows are `body` with a `subheadline` secondary line.
- **Shapes.** Cards have a 26 pt continuous corner radius. The content sheet's top corners are 34 pt.
- **Liquid Glass is for controls only:** toolbar buttons, the confirm button in sheets, and buttons such as Retry or "Use current location". No custom glass in the content layer.

## Navigation

```mermaid
flowchart LR
  Launch{Region set?} -- no --> Onboarding
  Launch -- yes --> Home
  Onboarding -- 現在地を使う / 地域を検索 --> Home
  Home -- toolbar: region button --> Region
  Home -- toolbar: gear --> Settings
  Home -- tap a day --> DayDetail
  DayDetail -- up / down buttons --> DayDetail
  Settings --> Region
  Settings --> SunnyLevel
  Settings --> About
```

Settings is a sheet with its own navigation stack. The day detail screen is pushed onto the Home stack.

## Home

![Home](images/home.jpg)

- **Toolbar** (system glass): a region button on the leading side (`location.fill` and the region name) and a gear button on the trailing side.
- **Header.** A full-bleed color area at the top of the scrolling content:
  - System orange when a sunny day is in range, `systemGray` when none is, and `systemGray2` while loading or when there is no data.
  - Text from top to bottom: 「次の晴れは」 (`headline`), the big 「あと3日」, the date and condition (`title3` semibold), then high / low / precipitation (`subheadline`).
  - A 64 pt white symbol sits at the top trailing corner.
- **Content sheet.** It overlaps the bottom of the header, and both scroll together (a stretchy header):
  - The sheet starts 34 pt above the bottom of the header and has 34 pt top corners and a soft upward shadow (black at 18 %, radius 18, y −4).
  - Scrolling up, the header fades out over 70 % of its height and moves up at 0.3× the scroll speed (parallax), so the sheet slides over it. Once the sheet reaches the top, the toolbar floats over the sheet with the system scroll edge effect, and no header color is left behind it.
  - Pulling down stretches the header color into the space above it; the header text moves down with the content. The refresh control shows on the header color.
- **時間ごとの予報** card: a horizontal strip of the next 24 hours with time, symbol, precipitation chance and temperature. The first cell is 「今」; the first hour of the next day shows its date (「10/9」) instead of 「0時」. The screenshots predate this and show 「今日の時間ごと」 with today's hours only.
- **10日間の天気** card. Each row shows:
  - the symbol, with the precipitation chance under it
  - the date (「今日」, then 「10月8日（木）」…)
  - the condition on a second line, in orange on sunny days
  - the high and the low (the low in `secondaryLabel`)
  - a chevron
  Tapping a row opens the day detail screen.
- **Footer:** the last-updated time, the Apple Weather mark and the 「データソース」 legal link.

![Home scrolled](images/home-scrolled.jpg)

### Header copy

| State | Big text | Line 2 | Line 3 | Color / symbol |
| --- | --- | --- | --- | --- |
| Sunny day in N ≥ 2 days | あと{N}日 | {M}月{D}日（{曜}）{condition} | 最高 {H}° 最低 {L}° 降水 {P}% | orange / day symbol |
| Tomorrow | あした | same | same | orange |
| Today | 今日 | same | same | orange |
| None in the 10-day range | まだ先かも | 10日先まで晴れの予報なし | 予報が変わったらここに出るよ | `systemGray` / `cloud.fill` |
| No data (fetch failed, nothing cached) | あと？日 | 天気を取得できなかったよ | 「もう一度試す」 button | `systemGray2` / `icloud.slash.fill` |
| Loading (first fetch) | spinner + 天気を取得中… | — | — | `systemGray2`; the sheet is redacted |

The 「今日」 and 「あした」 rows were not mocked; they follow the same layout.

### States

| No sunny day in range | Loading |
| --- | --- |
| ![No sunny day](images/home-no-sunny-day.jpg) | ![Loading](images/home-loading.jpg) |

| Refresh failed, cached data shown | Fetch failed, no data |
| --- | --- |
| ![Error with cache](images/home-error-cached.jpg) | ![Error without data](images/home-error-no-data.jpg) |

- **Refresh failed with cached data:** keep the cached forecast. Add a banner card at the top of the sheet: 「天気を更新できなかったよ」, 「今日 14:05 の予報を表示しています」 and a 「再試行」 glass button.
- **Fetch time** in the banner and the Home footer (「今日 14:05 に更新」) uses the system's relative date for the language: 「今日」, 「昨日」 and 「一昨日」 in Japanese, then the date (「2026/10/05 14:05」). The cache can be a day or more old, because the forecast is fetched once a day from 4:00 and may fail offline. The widget's 「前回の更新」 uses the same format.
- **Fetch failed with no data:** the header shows 「あと？日」 with a 「もう一度試す」 button. The sheet holds a single card: 「通信できる場所で、もう一度試してね」 with a short explanation and a hint about pull to refresh.

## Onboarding (no region yet)

![Onboarding](images/onboarding.jpg)

A `ContentUnavailableView`: a multicolor sun, 「どこの天気を調べる？」 and 「地域を決めると、次に晴れる日がわかるよ。」. There are two buttons: 「現在地を使う」 (orange, glass prominent) and 「地域を検索」 (glass). The navigation title is 次いつ晴れる？.

## Day detail

| Top | Scrolled |
| --- | --- |
| ![Day detail](images/day-detail.jpg) | ![Day detail scrolled](images/day-detail-scrolled.jpg) |

- It uses the same layered layout as Home. The header is orange on a sunny day and `systemGray` otherwise. It shows the date (`headline`), the condition as the big text, then high / low / precipitation, with the day's symbol at the top trailing corner.
- The toolbar has the system back button, plus up/down buttons (`chevron.up` / `chevron.down`) that move to the previous or next day.
- **時間ごと** card: one row per hour with time, symbol, condition, precipitation chance (20 % or more) and temperature.
- **その他** card: sunrise, sunset, UV index and wind, each with a multicolor symbol.
- The footer has the same attribution as Home.

## Settings

| Settings | 晴れの基準 |
| --- | --- |
| ![Settings](images/settings.jpg) | ![Sunny level](images/sunny-level.jpg) |

- A sheet with an inline title 「設定」 and a confirm button (`Button(role: .confirm)`).
- The rows are:
  - 地域 (`location.fill`, value 「東京都港区」 or 「現在地」)
  - 晴れの基準 (`sun.max.fill`, value = the current level), with the footer 「どんな天気の日を「晴れ」として数えるかを選べるよ。」
  - 気温 (`thermometer.medium`, value = the unit in use, 「°C」 or 「°F」), a menu picker with the choices of Apple's Weather app, in its order: 「摂氏（°C）」, 「華氏（°F）」 and 「システム設定を使用（°C）」 (the default: the system's temperature unit, shown in the parentheses, which follows the region unless changed in Settings > General > Language & Region). It applies to the app and the widgets.
  - 天気データについて (`info.circle`)
- The version string goes in the last footer.
- **晴れの基準** is a list of the four levels. Each row has a symbol, a title and a subtitle listing what counts by the condition names Home shows (WeatherKit's, such as 「快晴、ほぼ快晴」; the loosest level keeps its description instead of listing nine), and the selected row has an orange checkmark. The footer recommends 「雨が降らなければOK」 for laundry.

### Sunny levels

The levels are cumulative. Both the next-sunny-day search and the orange "sunny" styling use the selected level.

| Level (UI) | Counts as sunny (`WeatherCondition`) | Extra rule |
| --- | --- | --- |
| 快晴だけ | `.clear` | — |
| 晴れ (default, same as v1) | `.clear`, `.mostlyClear` | — |
| 晴れ時々くもりまで | + `.partlyCloudy` | — |
| 雨が降らなければOK | + `.mostlyCloudy`, `.cloudy`, `.haze`, `.breezy`, `.windy`, `.hot`, `.frigid` | daily precipitation chance < 30 % |

Fog, smoke, blowing dust, every kind of precipitation and every storm never count. The home copy stays 「次の晴れは」 at every level.

## Region

![Region](images/region.jpg)

- The first row is 「現在地を使う」 (`location.fill` in blue, subtitle 「今いる場所の天気を表示します」).
- Below it is a 「検索結果」 section that updates while the user types (#28). Each result shows a place name and a gray subtitle, and the current region has an orange checkmark.
- Search uses `.searchable`; on iOS 26 the field sits at the bottom.
- Results are areas only: prefectures, cities, wards and towns (「港区」, 「湊」), never street addresses or buildings.

## About weather data

![About](images/about.jpg)

- The Apple Weather mark (`WeatherService.shared.attribution`), a short note on the data and refresh, and the 「データソースと法的情報」 link.
- A 「いまの設定」 section shows the selected sunny level and which conditions count.

## Attribution

The Apple Weather mark and the legal link appear in three places: the Home footer, the day detail footer and About. The mockups use a dashed placeholder; the real mark comes from `WeatherService.shared.attribution`, in its light and dark variants. The medium and large widgets also show the mark; the small and Lock Screen widgets have no room for it, and the legal link stays in the app (#96).

## Widgets

| Home Screen | States | Lock Screen |
| --- | --- | --- |
| ![Home Screen widgets](images/widgets-home-screen.jpg) | ![Widget states](images/widgets-states.jpg) | ![Lock Screen widgets](images/widgets-lock-screen.jpg) |

- **Small:** 「次の晴れ」 with a symbol, 「あと3日」, 「10/10（土）快晴」 and the region name.
- **Medium:** the small layout plus the next five days (weekday, symbol, high). Sunny days get a light capsule behind them.
- **Large:** a header row like the small widget, then seven days (date, symbol, condition, high/low). Sunny rows are bold on a light capsule.
- **Background:** system orange when a sunny day is in range, `systemGray` otherwise.
- **States:**
  - None in range: 「まだ先かも」 / 「10日先まで晴れなし」. The medium widget still lists five days.
  - No data: 「あと？日」 / 「天気を取得できなかったよ」. The small widget adds 「タップして更新」; the medium widget adds the last update time.
- **Lock Screen:**
  - inline: 「☀ 次の晴れ あと3日（土）」; 「今日」 and 「あした」 go without the weekday. In English each state is its own short sentence to fit the line above the clock: "Sunny in 3 days (Sat)", "Sunny today", "Sunny tomorrow", "No sunny day soon", "Sunny in ? days".
  - circular: the symbol over 「3日」
  - rectangular: 「次の晴れ」 / 「あと3日」 / 「10/10（土）快晴」
  The system draws these in monochrome.
- The mockups are plain views at widget sizes, not a real widget extension. In the accented and clear Home Screen looks the system replaces the orange or gray background with its own material; the headline and the symbol are the accented parts.
- A widget without a region says 「あと？日」 / 「アプリで地域を選んでね」. The medium and large widgets draw their days redacted, where the forecast goes once a region is chosen.

## App icon

The three layers live in [`app-icon/`](app-icon/). They were traced as SVG from the v1 master [`app-icon-1024.png`](app-icon-1024.png) and are meant to be imported into Icon Composer in #97:

| Layer | File | Content |
| --- | --- | --- |
| 1 | `layer-1-background.svg` | Orange gradient, #F37E4F at the top to #F89A35 at the bottom |
| 2 | `layer-2-mane.svg` | White sun-shaped mane and the ears |
| 3 | `layer-3-face.svg` | Eyes, nose, mouth, whiskers, whisker dots and the bolt on the forehead (strokes slightly thicker than v1 so they survive small sizes) |

| Light | Dark | Tinted |
| --- | --- | --- |
| ![Light](app-icon/preview-light.svg) | ![Dark](app-icon/preview-dark.svg) | ![Tinted](app-icon/preview-tinted.svg) |

- **Dark:** near-black gradient background, orange mane, dark face. It is the inverse of the light icon and the closest to iOS 26 system dark icons.
- **Tinted:** the mane carries the shape; the face is cut out in the dark color.
- The trace is approximate. The final shapes, glass highlights and the clear look are tuned in Icon Composer.

## Implications for later tasks

- **#94 Storage**
  - Store the region as a name plus coordinates, or a "current location" flag.
  - Store the sunny level (default 晴れ).
  - Store the cached daily forecast (condition, high/low, precipitation chance, sunrise/sunset, UV, wind) and hourly forecast.
  - Store the last successful fetch time; the error banner and the widget need it.
- **#95 App layer**
  - Screens: Onboarding, Home, Day detail, Settings (sheet), Region, Sunny level, About.
  - Header states: sunny / none / loading / no data, plus the cached-data error banner.
  - The next-sunny-day logic takes the sunny level, including the 30 % rule.
  - Pull to refresh, and incremental region search with "use current location" (Core Location, when-in-use).
- **#96 Widgets**
  - Families: small, medium, large, `accessoryInline`, `accessoryCircular`, `accessoryRectangular`.
  - States: sunny, none in range, no data.
  - Show the region name.
  - Check whether widgets need attribution.
- **#97 Visuals**
  - The layered header and sheet: overlap, corner radius, shadow, fade and parallax values as above.
  - The SF Symbols palette mapping, system colors with only the orange accent, and glass on controls only.
  - The Icon Composer icon from the three layers, with the dark and tinted looks above.
- **#98 English**
  - Every string in this spec gets an English source string. The Japanese above is the `ja` translation.
  - The English app name is "Next Sunny Day" (home screen, widget gallery, Settings).
