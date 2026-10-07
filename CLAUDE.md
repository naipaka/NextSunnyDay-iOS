# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

NextSunnyDay (次いつ晴れる？) — SwiftUI iOS app that shows when the next sunny day will be, plus a home-screen Widget. Originally written with Xcode 12 / Swift 5.3; currently builds with Xcode 26.4.1 (Swift language mode 5, iOS deployment target 26.0).

## Setup

No API key is needed. Weather data comes from **WeatherKit**: both targets carry the `com.apple.developer.weatherkit` entitlement, and the App IDs (`com.naipaka.NextSunnyDay`, `com.naipaka.NextSunnyDay.NextSunnyDayWidget`) plus the team's WeatherKit App Service are enabled in the Developer portal. Without that, builds succeed but fetches fail at runtime.

## Common commands

Build:
```sh
xcodebuild -scheme NextSunnyDay -configuration Debug \
  -destination 'generic/platform=iOS Simulator' build
```

Test:
```sh
xcodebuild -scheme NextSunnyDay -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17' test
```

- Tests use **Swift Testing** (`import Testing`, `@Test`, `#expect`) in the `NextSunnyDayTests` target. There is no UI test target.

Run a single test by appending `-only-testing:NextSunnyDayTests/<SuiteName>/<testFunction>()`.

Format and lint (the `swift-format` bundled with Xcode, config in `.swift-format` = the tool's defaults: 2-space indent, 100 columns):
```sh
xcrun swift-format format -i -r -p NextSunnyDay NextSunnyDayWidget NextSunnyDayTests
xcrun swift-format lint --strict -r -p NextSunnyDay NextSunnyDayWidget NextSunnyDayTests
```
CI runs the strict lint before building, so any warning fails CI. Format before committing.

## Architecture

### MVVM + Combine via `ViewModelObject`

All ViewModels conform to the `ViewModelObject` protocol (`NextSunnyDay/Protocol/ViewModelObject.swift`), which enforces a three-object split:

- **Input** (`InputObject`): user events as `PassthroughSubject`s (e.g. button taps).
- **Binding** (`BindingObject`): two-way state bound to SwiftUI (`@Published` flags like `isLoading`, sheet visibility).
- **Output** (`OutputObject`): one-way state derived from the model layer (`@Published` data shown in the view).

The protocol merges `binding` and `output` `objectWillChange` publishers so Views observe a single source. When adding a ViewModel, define a feature-specific protocol that refines these three (see `HomeViewModel.swift` for the canonical pattern) and wire `Input` subjects to `Binding`/`Output` mutations via `Combine.sink` stored in `cancellables`.

### Data flow

- **WeatherKit** is fetched by `WeatherKitProvider` (`API/Weather/WeatherProviding.swift`), which returns the 10-day daily forecast as the domain model `[DailyForecast]` (`Model/DailyForecast.swift`; `ForecastLocation` is the place). The async protocol `WeatherProviding` is the seam — inject fakes in tests/previews via this protocol (see how `HomeViewModel` is constructed in `NextSunnyDayApp.swift`).
- "Sunny" is `WeatherCondition.isSunny` (`.clear`, `.mostlyClear`); the next sunny day is `[DailyForecast].nextSunnyDay`. Both are unit-tested.
- **Realm bridge** (`Model/DailyWeatherForecastEntity+DailyForecast.swift`): maps `DailyForecast` into the Realm entity (`Weather.main` = condition raw value, `Weather.icon` = SF Symbol name, temperatures in °C) and back, so the existing UI reads domain values. Days saved by v1 (OpenWeather) don't map and are skipped.
- **Apple Weather attribution** (mark + legal link from `WeatherService.shared.attribution`) is shown in `AboutWeatherForecastView`.
- **Realm** is the single source of truth on-device. `DailyWeatherForecastEntity` (`Model/`) is a Realm `Object` plus a CRUD extension. The Realm file lives in the App Group container `group.com.naipaka.NextSunnyDay` so the Widget can read the same DB.
- ViewModels observe Realm `Results` via `NotificationToken`, push updates into `output`, and call `WidgetCenter.shared.reloadAllTimelines()` after writes so the Widget refreshes.
- Forecast staleness check: a fetch is triggered when the earliest stored daily entry is older than ~24h (app) / ~20h (widget). Full flowcharts: `docs/architecture/weather-fetch-flow.md` — keep them in sync when changing fetch logic.

### Xcode project format

`NextSunnyDay.xcodeproj` uses **folder-synchronized groups** (objectVersion 77): `NextSunnyDay/`, `NextSunnyDayWidget/` and `NextSunnyDayTests/` are synced to their targets, so adding, moving or deleting a file in those folders needs no `project.pbxproj` change. Exceptions live in `PBXFileSystemSynchronizedBuildFileExceptionSet` entries:

- Each target's `Info.plist` is excluded from its own target (it is used via `INFOPLIST_FILE`, not copied as a resource).
- Files under `NextSunnyDay/` that the widget also compiles or bundles are listed as membership exceptions for `NextSunnyDayWidgetExtension`. When the widget needs another app file, add its path there (or tick the widget in Xcode's Target Membership).

### Widget target

`NextSunnyDayWidget/` is a separate target sharing source with the app (Model, API, ViewModels for the widget views). Its `Provider.getTimeline` directly reads the shared Realm and may also call `WeatherFetcher`. Supported families: `.systemSmall`, `.systemMedium`.

### Localization & resources

- **String Catalogs**, auto-extracted. Write UI text in **English** in code: `Text("Settings")`, `.navigationBarTitle("…")` and other `LocalizedStringKey` APIs for literals in views, `String(localized: "…")` where a `String` is needed (ViewModel outputs, `@Published` defaults). Xcode adds the keys to `NextSunnyDay/Resources/Localizable.xcstrings`; the Japanese copy is the `ja` translation there. English is the source/development language, Japanese the only translation (#98 reviews the English copy).
- `Localizable.xcstrings` is a member of both the app and the widget (membership exception), so there is one catalog for both. `InfoPlist.xcstrings` localizes `CFBundleDisplayName` (`NextSunnyDay` / `次いつ晴れる？`).
- Non-UI values stay plain literals in code and out of the catalog: SF Symbol names (`Image(systemName: "xmark")`), the `"-"` placeholder, the widget `kind`.
- **Colors** come from `Assets.xcassets` via Xcode's generated asset symbols: `Color(.nextSunnyDayText)`. The `Blue` asset collides with `UIColor.blue`, so write `Color(ColorResource.blue)`.
- There are no third-party resource generators, build-tool plugins or script build phases.
- SPM versions are pinned in `NextSunnyDay.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` (committed). Realm is still `realm-cocoa` 5.5.2; it builds and runs on Xcode 26 but is very old.

## Docs

`docs/` holds design docs (`architecture/`, Mermaid diagrams), the approved 2.0 design spec (`design/spec.md`, the source of truth for screens, states, copy and the sunny-level rules) and the app icon master (`design/app-icon-1024.png`, plus layered SVGs in `design/app-icon/`). See `docs/README.md` for the index. This is an OSS repo: write docs, code comments, and commit messages in English (UI text in code is English source strings; Japanese lives in the String Catalog).

## Branching

Single long-lived branch: `main` (default). There is no `develop`.

- The owner commits and pushes directly to `main`; do not open PRs for their changes.
- A repository ruleset ("Protect main") requires a PR for everyone else and blocks force-pushes and deletion of `main`; the admin role bypasses it.
- CI (`main.yml`) runs on pushes and PRs to `main`, skipping Markdown/`docs/`-only changes. It lints with `swift-format --strict` on the `macos-26` runner with Xcode 26.4.1. On pushes to `main` it then only builds for `generic/platform=iOS Simulator` (no simulator boot, a few minutes); on PRs it runs `NextSunnyDayTests` on an iPhone 17 (iOS 26.4.1) simulator. Because pushes don't run tests, **run the tests locally before pushing to `main`**. Keep `DEVELOPER_DIR` in sync with the local Xcode version.

## Known stale dependencies

The project was dormant from 2020 and is being revived. Realm (`realm-cocoa` 5.5.2) is the only third-party dependency left and is very old.
