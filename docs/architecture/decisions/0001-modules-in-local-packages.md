# 1. Shared code lives in local Swift packages, one package per module

- Status: Accepted (2026-10-07, #95)
- Scope: how the app, the widget and their shared code are split and named. The app layer inside the Xcode targets is decided separately.

## Context

The app and the widget share models, weather fetching, storage and the sunny-day rules. Until 1.x everything sat in the app folder, and the widget compiled selected app files through target membership exceptions. Nothing stopped shared code from reaching into app code, and the widget compiled more than it needed.

The owner wants this app to serve as a reference architecture for later apps. The goal is that **dependency direction and boundaries are enforced by structure, not by convention**:

- Each part is complete on its own and does not need to know who uses it. Its tests cover only what it promises, so a defect in a part is caught small, by that part's tests.
- Parts are put together in one place. Any part can be swapped or removed without touching the others.
- Rules that live only in prose (a README, CLAUDE.md) get broken, by people and by coding agents alike. A rule enforced by the build stops the violation where it is written, and the agent fixes it itself.

### Why fine-grained modules

Splitting into many small modules makes the dependency graph visible in the manifests, enforces it at build time, gives every part its own fast tests (on the Mac, without a simulator), keeps the context needed to change a part small, and makes a change to a manifest stand out in review as an architecture change.

The usual costs of splitting are mechanical: a manifest per module with repeated settings, `public` on everything that crosses a boundary, explicit initializers, and wiring tests per package. With coding agents writing most of the code, these costs mostly disappear. What does not disappear is the cost of a boundary in the wrong place: a boundary is a promise, and splitting things that change together only hides the coupling behind `public` API that every change has to cross. An agent will keep a wrong boundary working rather than question it. So the rule is not "split as little as possible" but **"put boundaries only where things change independently"**.

## Decision

### Layers and rules

1. **core** wraps one piece of the outside world and knows no feature. Core modules do not depend on each other.
2. **feature** is one capability of the app (not a screen). It depends only on core, never on another feature.
3. **The app and the widget are the only places that assemble parts.** Screens, navigation and dependency injection live in the Xcode targets.
4. Boundaries go only where things change independently.

### Modules

| Layer | Module | Wraps / does | Depends on |
| --- | --- | --- | --- |
| core | `Weather` | WeatherKit. Returns its own value types (forecast, condition enum), localized condition names, and the Apple Weather attribution | — |
| core | `Location` | Core Location: the current location, once | — |
| core | `PlaceSearch` | MapKit: completions while typing, completion → name + coordinate, coordinate → place name (`MKReverseGeocodingRequest`) | — |
| core | `AppGroup` | The App Group identifiers only: the shared `UserDefaults` suite and the caches location | — |
| feature | `Region` | The list of regions (one for now), stored with IDs; resolving a region's coordinate and display name | Location, PlaceSearch, AppGroup |
| feature | `Forecast` | Keeping forecasts fresh: per-region cache, freshness check, fetch, cleanup of removed regions | Weather, AppGroup |
| feature | `SunnyDay` | The four sunny levels (including the 30 % rule), storing the level, finding the next sunny day | Weather, AppGroup |

- Core modules share coordinates as Apple's `CLLocationCoordinate2D`, so none of them depends on another for a coordinate type.
- Foundation APIs that are already testable (`UserDefaults` with a test suite, files in a temporary directory) are used directly by the feature that owns the data, not wrapped in core. Core wraps what needs entitlements, permissions or the network: WeatherKit, Core Location, MapKit search.
- `Weather` keeps WeatherKit's types inside. In version 1 the OpenWeather condition codes (800, 801) leaked into the sunny rule, so swapping the data source touched the logic; an own condition enum prevents that. Localized names still come from WeatherKit, inside `Weather`.
- The widget uses `Region` (read only), `Forecast` and `SunnyDay`.
- UI strings stay in the app and widget targets, so there is still one String Catalog with English source strings extracted by Xcode.

### Packages and targets

- The Xcode project keeps the app, widget and app test targets. **Each module is its own local Swift package** with its own `Package.swift`, sources and tests; the app and widget targets link the products they import.
- Packages use swift-tools-version 6.2 and the Swift 6 language mode, with the default (nonisolated) isolation. Platforms are iOS 26 and macOS 26 so that package tests run with `swift test` on the Mac, without a simulator.

### Naming

- Modules are named after their area with a plain noun (`Weather`, `Region`), like Apple's own packages (`Collections`, `Crypto`). The layer is shown by the folder, not by a suffix.
- Types inside get role names (`RegionStore`, `ForecastCache`), so no type has the same name as its module. A module containing a type of its own name cannot be built for distribution and makes `Module.Name` ambiguous ([SE-0491](https://forums.swift.org/t/se-0491-module-selectors-for-name-disambiguation/82124)); Apple's packages avoid it with names like `DequeModule`.
- Types are not suffixed `Client` across the board. That is a TCA (Point-Free) convention; plain role names describe these types better.

## Considered options

**Where shared code lives**

- *A `Shared/` folder synced to both targets.* Simplest, and no `public` needed. Rejected because nothing enforces direction inside the folder; a violation shows up only as a widget build failure.
- *Keep the layer folders (`Model/`, `View/`, `ViewModel/`) with membership exceptions.* Rejected for the same reason, plus the exception list to maintain.

**Package layout**

- *Package-centric (isowords style):* a root `Package.swift` holds every module including the app's screens (`AppFeature`), and the Xcode targets are thin shells (isowords' iOS target is one `App.swift`). SwiftPM cannot build app bundles or extensions (its products are library, executable and plugin), so a thin Xcode project remains either way. Rejected because screens in packages need a String Catalog per module (`Bundle.module`), which breaks the single, auto-extracted catalog; Ice Cubes keeps one catalog only by writing key-style strings resolved from the main bundle, and Mastodon uses a SwiftGen-generated localization module. Moving the assembly into a module adds little at this size.
- *One package with many targets (Mastodon's `MastodonSDK`).* One manifest shows the whole graph, `package` access (SE-0386) can share code between modules, and one `swift test` runs everything. Rejected because inside one package an undeclared import of a sibling module compiles by default (tested with Swift 6.3.1, also after a clean build); only `--explicit-target-dependency-import-check=error` catches it. With one package per module, building a package on its own fails on any module outside its declared graph, without flags. NetNewsWire (`Modules/`, about 17 packages), Ice Cubes (`Packages/`, 13) and Wikipedia also use several packages.

**Granularity**

- *One core package for everything shared.* Rejected: it mixed things that change for different reasons (the WeatherKit wrapper, the storage format, the spec's sunny rules), and put feature concepts such as the sunny level into core.
- *Screens as features (Home, Settings, …).* Rejected: they are views over the same data, not independent capabilities. Screens combine capabilities, so they belong to the assembling layer.
- *A shared `Models` module.* Rejected: a catch-all every module depends on. Each type lives with the module that provides it.
- *Plural module names (`Places`, `Forecasts`) to dodge type-name clashes.* Rejected: the clash is better avoided with role-named types.

## Consequences

- Seven packages, each with its own manifest and tests. Repeated manifest settings are accepted (see "Why fine-grained modules").
- SwiftPM does not fully enforce declared dependencies, so CI has to check them: see [0002](0002-dependency-checks-in-ci.md).
- The app layer (models, injection, Swift 6 settings for the targets) is still open and gets its own record.
- The packages live under `Packages/`, one folder per layer, so the layer is visible in the path:

  ```
  Packages/
    Core/       Weather/, Location/, PlaceSearch/, AppGroup/
    Features/   Region/, Forecast/, SunnyDay/
  ```

  `Packages/` is the most common name among SwiftUI apps with local packages (Ice Cubes, IcySky) and says what the folders contain; NetNewsWire uses `Modules/` and DuckDuckGo `LocalPackages/`.
