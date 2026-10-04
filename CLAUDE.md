# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

NextSunnyDay (次いつ晴れる？) — SwiftUI iOS app that shows when the next sunny day will be, plus a home-screen Widget. Originally written with Xcode 12 / Swift 5.3; currently builds with Xcode 26.4.1 (Swift language mode 5, iOS deployment target 14.0).

## Setup

1. (Optional) `mint bootstrap` — installs pinned tools from `Mintfile` (SwiftLint, LicensePlist). Not required to build: the SwiftLint and LicensePlist build phases print a warning and skip when Mint is missing.
2. Create `NextSunnyDay/API/AccessTokens.swift` containing your OpenWeather API key. This file is gitignored and required to build:
   ```sh
   echo "let OPEN_WEATHER_API_KEY = \"{your key}\"" > ./NextSunnyDay/API/AccessTokens.swift
   ```
   CI injects this from the `OPEN_WEATHER_API_KEY` secret (see `.github/workflows/main.yml`).

## Common commands

Build:
```sh
xcodebuild -scheme NextSunnyDay -configuration Debug \
  -destination 'generic/platform=iOS Simulator' -skipPackagePluginValidation build
```

Test:
```sh
xcodebuild -scheme NextSunnyDay -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17' -skipPackagePluginValidation test
```

- Do not pass `-sdk iphonesimulator`: it forces the R.swift build-tool plugin to be built for the simulator, and the build fails with `execvp() of '.../Debug/rswift' failed`.
- `-skipPackagePluginValidation` is needed on the command line because of the R.swift plugin. In the Xcode GUI, trust the plugin once when prompted.
- `NextSunnyDayTests` / `NextSunnyDayUITests` contain only the Xcode template tests.

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
- **R.swift 7** generates typed accessors via the `RswiftGenerateInternalResources` SPM build-tool plugin on both the app and widget targets; the generated file lives in DerivedData, not the repo. Reference resources as `R.string.widget.kind()`, `R.color.blue()` etc., not raw string keys. To pass a locale, use `R.string(preferredLanguages:)…` (the R.swift 5 `preferredLanguages:` argument on each accessor no longer exists).
- SPM versions are pinned in `NextSunnyDay.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` (committed). Realm is still `realm-cocoa` 5.5.2; it builds and runs on Xcode 26 but is very old.

## SwiftLint

Config in `.swiftlint.yml` is opinionated and enables many opt-in rules. Notable disabled rules include `force_unwrapping`, `force_cast`, `force_try` — force-unwrap when it's genuinely safe. The `swiftlint.yml` workflow runs SwiftLint 0.62.2 (Linux binary) on pushes and PRs to `main` that touch Swift files; it fails only on errors, not warnings.

## Docs

`docs/` holds design docs (`architecture/`, Mermaid diagrams) and the app icon master (`design/app-icon-1024.png`). See `docs/README.md` for the index. This is an OSS repo: write docs, code comments, and commit messages in English (UI strings stay Japanese).

## Branching

Single long-lived branch: `main` (default). There is no `develop`.

- The owner commits and pushes directly to `main`; do not open PRs for their changes.
- A repository ruleset ("Protect main") requires a PR for everyone else and blocks force-pushes and deletion of `main`; the admin role bypasses it.
- CI (`main.yml`) runs on pushes and PRs to `main`, skipping Markdown/`docs/`-only changes. It builds and runs `NextSunnyDayTests` on the `macos-26` runner with Xcode 26.4.1 and an iPhone 17 (iOS 26.4) simulator. Keep `DEVELOPER_DIR` in sync with the local Xcode version.

## Known stale tooling

The project was dormant from 2020 and is being revived. Mint tool versions (SwiftLint 0.40.3, LicensePlist 3.0.5) are old and may not build with current Swift; CI no longer uses Mint. Realm is `realm-cocoa` 5.5.2.
