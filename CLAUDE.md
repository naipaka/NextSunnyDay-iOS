# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

NextSunnyDay (次いつ晴れる？) — SwiftUI iOS app that shows when the next sunny day will be, plus a home-screen Widget. Xcode 12.0.1 / Swift 5.3.

## Setup

1. `mint bootstrap` — installs pinned tools from `Mintfile` (SwiftLint, R.swift, LicensePlist).
2. Create `NextSunnyDay/API/AccessTokens.swift` containing your OpenWeather API key. This file is gitignored and required to build:
   ```sh
   echo "let OPEN_WEATHER_API_KEY = \"{your key}\"" > ./NextSunnyDay/API/AccessTokens.swift
   ```
   CI injects this from the `OPEN_WEATHER_API_KEY` secret (see `.github/workflows/main.yml`).

## Common commands

Build (matches CI):
```sh
xcodebuild -sdk iphonesimulator -configuration Debug -scheme NextSunnyDay build | xcpretty
```

Test (matches CI — iPhone 11 Pro Max simulator):
```sh
xcodebuild -sdk iphonesimulator -configuration Debug -scheme NextSunnyDay \
  -destination 'platform=iOS Simulator,name=iPhone 11 Pro Max' clean test | xcpretty
```

Run a single test by appending `-only-testing:NextSunnyDayTests/<ClassName>/<testMethod>`.

Lint locally:
```sh
mint run swiftlint
```

## Architecture

### MVVM + Combine via `ViewModelObject`

All ViewModels conform to the `ViewModelObject` protocol (`NextSunnyDay/Protocol/ViewModelObject.swift`), which enforces a three-object split:

- **Input** (`InputObject`): user events as `PassthroughSubject`s (e.g. button taps).
- **Binding** (`BindingObject`): two-way state bound to SwiftUI (`@Published` flags like `isLoading`, sheet visibility).
- **Output** (`OutputObject`): one-way state derived from the model layer (`@Published` data shown in the view).

The protocol merges `binding` and `output` `objectWillChange` publishers so Views observe a single source. When adding a ViewModel, define a feature-specific protocol that refines these three (see `HomeViewModel.swift` for the canonical pattern) and wire `Input` subjects to `Binding`/`Output` mutations via `Combine.sink` stored in `cancellables`.

### Data flow

- **OpenWeatherMap One Call API** is fetched by `WeatherFetcher` (`API/OpenWeatherAPI/`) returning a `Combine` publisher of `DailyWeatherForecastResponse`. The protocol `WeatherFetchable` is the seam — inject mocks in tests/previews via this protocol (see how `HomeViewModel` is constructed in `NextSunnyDayApp.swift`).
- **Realm** is the single source of truth on-device. `DailyWeatherForecastEntity` (`Model/`) is a Realm `Object` plus a CRUD extension. The Realm file lives in the App Group container `group.com.naipaka.NextSunnyDay` so the Widget can read the same DB.
- ViewModels observe Realm `Results` via `NotificationToken`, push updates into `output`, and call `WidgetCenter.shared.reloadAllTimelines()` after writes so the Widget refreshes.
- Forecast staleness check: a fetch is triggered when the earliest stored daily entry is older than ~24h (app) / ~20h (widget). Full flowcharts: `docs/architecture/weather-fetch-flow.md` — keep them in sync when changing fetch logic.

### Widget target

`NextSunnyDayWidget/` is a separate target sharing source with the app (Model, API, ViewModels for the widget views). Its `Provider.getTimeline` directly reads the shared Realm and may also call `WeatherFetcher`. Supported families: `.systemSmall`, `.systemMedium`.

### Localization & resources

- Strings live under `NextSunnyDay/Resourece/strings/` (note the misspelling — keep it) and `NextSunnyDay/ja.lproj/`. Japanese is the only supported locale.
- **R.swift** generates typed accessors. Reference resources as `R.string.widget.kind()` etc., not raw string keys. The generated file is excluded from SwiftLint (`NextSunnyDay/*/R.generated.swift`).

## SwiftLint

Config in `.swiftlint.yml` is opinionated and enables many opt-in rules. Notable disabled rules include `force_unwrapping`, `force_cast`, `force_try` — force-unwrap when it's genuinely safe. `swiftlint.yml` workflow runs on PRs to `main` that touch Swift files.

## Docs

`docs/` holds design docs (`architecture/`, Mermaid diagrams) and the app icon master (`design/app-icon-1024.png`). See `docs/README.md` for the index. This is an OSS repo: write docs, code comments, and commit messages in English (UI strings stay Japanese).

## Branching

Single long-lived branch: `main` (default). There is no `develop`.

- The owner commits and pushes directly to `main`; do not open PRs for their changes.
- A repository ruleset ("Protect main") requires a PR for everyone else and blocks force-pushes and deletion of `main`; the admin role bypasses it.
- CI (`main.yml`) runs on pushes to `main` and PRs to `main`.

## Known stale tooling

The project was dormant from 2020 and is being revived. CI still pins `/Applications/Xcode_12.app`, `actions/*@v2`, and an iPhone 11 Pro Max simulator, which current GitHub runners no longer provide, so CI is expected to fail until updated. Mint tool versions (SwiftLint 0.40.3, R.swift 5.2.2) are similarly old.
