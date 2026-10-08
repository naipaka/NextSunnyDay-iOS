# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

NextSunnyDay (次いつ晴れる？) — SwiftUI iOS app that shows when the next sunny day will be, plus a home-screen Widget. Originally written with Xcode 12 / Swift 5.3; currently builds with Xcode 26.4.1 (Swift 6 language mode, iOS deployment target 26.0).

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

- Tests use **Swift Testing** (`import Testing`, `@Test`, `#expect`). The app's tests (state holders, `LegacyRealmCleanup`) are in the `NextSunnyDayTests` target; there is no UI test target.

Run a single test by appending `-only-testing:NextSunnyDayTests/<SuiteName>/<testFunction>()`.

Each package under `Packages/` builds and tests on its own on the Mac, without a simulator:
```sh
for p in Packages/Core/* Packages/Features/*; do (cd "$p" && swift test); done
```

Format and lint (the `swift-format` bundled with Xcode, config in `.swift-format` = the tool's defaults: 2-space indent, 100 columns):
```sh
xcrun swift-format format -i -r -p NextSunnyDay NextSunnyDayWidget NextSunnyDayTests Packages
xcrun swift-format lint --strict -r -p NextSunnyDay NextSunnyDayWidget NextSunnyDayTests Packages
```
CI runs the strict lint before building, so any warning fails CI. Format before committing.

## Architecture

The decisions and their reasons are in `docs/architecture/decisions/` (ADRs 0001–0005); read them before changing the structure.

### Packages (`Packages/`)

Shared code lives in local Swift packages, one package per module (ADR 0001). Swift 6, tools version 6.2, nonisolated by default, with `NonisolatedNonsendingByDefault`, `InferIsolatedConformances` and `MemberImportVisibility` enabled.

| Layer | Module | Does | Depends on |
| --- | --- | --- | --- |
| `Core/` | `Weather` | WeatherKit: `WeatherKitProvider` returns `WeatherForecast` (`DayForecast`, `HourForecast`, own `WeatherCondition` with `localizedName`) and the attribution | — |
| `Core/` | `Location` | Core Location: `CoreLocationProvider.currentCoordinate()`, once | — |
| `Core/` | `PlaceSearch` | MapKit: completions while typing, completion → place, reverse geocoding | — |
| `Core/` | `AppGroup` | `AppGroupContainer`: the shared `UserDefaults` and caches directory | — |
| `Features/` | `Region` | `SavedRegion`, `RegionStore`, `RegionSearch`, `RegionLocator` | Location, PlaceSearch, AppGroup |
| `Features/` | `Forecast` | `CachedForecast` (freshness), `ForecastCache`, `ForecastUpdater` | Weather, AppGroup |
| `Features/` | `SunnyDay` | `SunnyLevel` (the four levels, 30 % rule), `nextSunnyDay(in:)`, `SunnyLevelStore` | Weather, AppGroup |

- Core modules don't depend on each other; features depend only on core, never on each other. Only the app and the widget assemble them.
- Every module a target imports must be its declared direct dependency (ADR 0002), in packages and in the Xcode targets.
- Public initializers don't use default arguments that reach into another module (such as `defaults: UserDefaults = AppGroupContainer.userDefaults`): a default argument is compiled into the caller, which then needs that module linked. Add an argument-free `init()` inside the module instead.
- Each core package has a fake in a `…Testing` module (`WeatherTesting`, `LocationTesting`, `PlaceSearchTesting`). `WeatherTesting` decodes forecasts recorded from WeatherKit (`WeatherRecording`), read from its source folder (`Recordings/`, excluded from the target) so that they are never copied into the app; they work on the Mac and in a simulator, not on a device.
- WeatherKit has a type named `Weather`, which hides the `Weather` module in a file that imports both. Only the `Weather` package imports WeatherKit.

### App layer (ADR 0005)

- **State lives in the least common ancestor of the views that use it.** Shared state is three `@Observable` state holders in `NextSunnyDay/SharedState/`, created in `NextSunnyDayApp` and put into the environment: `RegionSelection` (the chosen region), `SunnyLevelSelection` and `RegionForecast` (the forecast of the selected region and how its last fetch went). Everything else is `@State` in the screen; a screen uses an `@Observable` class only when updating its state is logic.
- **State holders don't depend on each other.** The view that needs two pieces of state combines them (Home passes the forecast and the sunny level to `SunnyLevel.nextSunnyDay(in:)`), and views say when work happens (`task(id:)`, `refreshable`, button actions).
- **Views contain no logic.** `body` only reads state and computes without side effects; side effects go in actions and lifecycle closures.
- **Features reach the app through `AppFeatures`** (`NextSunnyDay/App/`): `.live` for the app; `AppFeatures.preview(_:)` builds them on the fakes for previews. State holders get features through their initializers; views get state holders with `@Environment(Type.self)` and `RegionSearch` / `ForecastUpdater` through `@Entry` environment values.
- **Previews:** wrap a screen in `PreviewHost(<scenario>)` (`App/PreviewHost.swift`), which sets up the state holders on the fakes. Don't put it under `#if DEBUG`: `#Preview` is compiled in Release too, and the Release build fails. Check `-configuration Release` builds after changing previews. Scenarios cover the screen states (`.tokyo`, `.singapore`, `.loading`, `.refreshFailed`, `.offline`, `.locationDenied`, `.noRegion`).
- **Tests** use real features with fakes only for the outside world (the core modules), plus a test `UserDefaults` suite and a temporary directory.
- Swift settings: the app is `MainActor` by default; the widget and the tests are nonisolated by default; all targets use Approachable Concurrency and Member Import Visibility.
- Fetch rules and flowcharts: `docs/architecture/weather-fetch-flow.md` — keep it in sync when changing fetch logic.

### Xcode project format

`NextSunnyDay.xcodeproj` uses **folder-synchronized groups** (objectVersion 77): `NextSunnyDay/`, `NextSunnyDayWidget/` and `NextSunnyDayTests/` are synced to their targets, so adding, moving or deleting a file in those folders needs no `project.pbxproj` change. The local packages are `XCLocalSwiftPackageReference`s; linking another product to a target adds an `XCSwiftPackageProductDependency`, a `PBXBuildFile` in its Frameworks phase and an entry in the target's `packageProductDependencies`. Exceptions live in `PBXFileSystemSynchronizedBuildFileExceptionSet` entries:

- Each target's `Info.plist` is excluded from its own target (it is used via `INFOPLIST_FILE`, not copied as a resource).
- The widget shares only `Assets.xcassets` and `Resources/Localizable.xcstrings` from `NextSunnyDay/` (membership exceptions for `NextSunnyDayWidgetExtension`). Shared code goes into a package, not into these exceptions.

### Widget target

`NextSunnyDayWidget/` uses `Region` (read only), `Forecast` and `SunnyDay`. Its `Provider.getTimeline` reads the region, the sunny level and the cached forecast, and fetches when the forecast isn't fresh. Supported families: `.systemSmall`, `.systemMedium`. The widget's redesign, schedule and location handling are #96.

### Localization & resources

- **String Catalogs**, auto-extracted. Write UI text in **English** in code: `Text("Settings")`, `.navigationBarTitle("…")` and other `LocalizedStringKey` APIs for literals in views, `String(localized: "…")` or `LocalizedStringResource` where a `String` or a value is needed. Data from WeatherKit and place names are shown with `Text(verbatim:)`. Xcode adds the keys to `NextSunnyDay/Resources/Localizable.xcstrings`; the Japanese copy is the `ja` translation there. English is the source/development language, Japanese the only translation (#98 reviews the English copy).
- `xcodebuild` doesn't add new keys to the catalog (Xcode does when building in the IDE). When adding UI text from the command line, add the key with its `ja` translation to `Localizable.xcstrings` yourself; the keys a build emits are in the `.stringsdata` files under DerivedData.
- `Localizable.xcstrings` is a member of both the app and the widget (membership exception), so there is one catalog for both. `InfoPlist.xcstrings` localizes `CFBundleDisplayName` (`NextSunnyDay` / `次いつ晴れる？`).
- Non-UI values stay plain literals in code and out of the catalog: SF Symbol names (`Image(systemName: "xmark")`), the `"-"` placeholder, the widget `kind`.
- **Colors** come from `Assets.xcassets` via Xcode's generated asset symbols: `Color(.nextSunnyDayText)`. The `Blue` asset collides with `UIColor.blue`, so write `Color(ColorResource.blue)`.
- There are no third-party resource generators, build-tool plugins or script build phases.
- The only Swift packages are the local ones under `Packages/`; there are no third-party dependencies. Keep it that way unless there is a strong reason.

## Docs

`docs/` holds design docs (`architecture/`, Mermaid diagrams), the approved 2.0 design spec (`design/spec.md`, the source of truth for screens, states, copy and the sunny-level rules) and the app icon master (`design/app-icon-1024.png`, plus layered SVGs in `design/app-icon/`). See `docs/README.md` for the index. This is an OSS repo: write docs, code comments, and commit messages in English (UI text in code is English source strings; Japanese lives in the String Catalog). Issue comments, commits and docs read as written by the owner: state decisions and their reasons, never the chat that led to them, and refer only to things visible in the repo or on GitHub (see the Writing on GitHub section of `.claude/skills/next-task/SKILL.md`).

## Branching

Single long-lived branch: `main` (default). There is no `develop`.

- The owner commits and pushes directly to `main`; do not open PRs for their changes.
- A repository ruleset ("Protect main") requires a PR for everyone else and blocks force-pushes and deletion of `main`; the admin role bypasses it.
- CI (`main.yml`) runs on pushes and PRs to `main`, skipping Markdown/`docs/`-only changes. It lints with `swift-format --strict` on the `macos-26` runner with Xcode 26.4.1. On pushes to `main` it then only builds for `generic/platform=iOS Simulator` (no simulator boot, a few minutes); on PRs it runs `NextSunnyDayTests` on an iPhone 17 (iOS 26.4.1) simulator. Because pushes don't run tests, **run the tests locally before pushing to `main`**. Keep `DEVELOPER_DIR` in sync with the local Xcode version.
