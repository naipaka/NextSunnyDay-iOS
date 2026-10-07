# 5. The app layer keeps state in Observation-based state holders, not per-screen view models

- Status: Draft (#95). Sections marked *Open* are not decided yet.
- Builds on [0001](0001-modules-in-local-packages.md): the app and the widget assemble the modules; this record covers how their screens hold state and reach the features.

## Context

Version 1 used MVVM with Combine: every screen had a view model conforming to `ViewModelObject`, split into Input, Binding and Output objects. 2.0 moves to Observation (`@Observable`), Swift Concurrency and the Swift 6 language mode.

With Observation, SwiftUI tracks each property that `body` reads, per instance. `@State`, `@Environment` and `@Bindable` replace `@StateObject`, `@EnvironmentObject` and `@ObservedObject`. SwiftUI's environment is scoped to the view tree, so a value placed on a subtree is visible only inside it.

The app needs rules for where each kind of state lives, so that every piece of data has a single source of truth and screens stay thin.

## Decision

### Kinds of state

| Kind | Lives in | Example |
| --- | --- | --- |
| **Shared state**, used by several screens | An `@Observable` class placed in the environment | The regions, their forecasts, the sunny level |
| **Ephemeral view state**, owned by one view | `@State` with plain values, or a plain struct when several values belong together | The search text, whether a sheet is shown |
| **Screen-scoped state with I/O**, owned by one screen | An `@Observable` class the screen creates with `@State` | The search results while typing a region name |

- **Views never call features directly.** They read state from, and send actions to, a state holder; the state holder calls the features.
- A screen-scoped state holder is created **only when a screen-local concern has both state and I/O**. It holds **one concern**, and **never copies shared data**: it reads shared state from the shared state holder instead.
- A screen-scoped state holder lives in the app target, in the folder of its area (for example `Region/`), next to the screen that uses it. It does not go into a feature package: it exists for that screen, and features know nothing about screens.

### Naming

- The role is called a **state holder** (the term from Android's architecture guide; Apple has no specific term and calls any `@Observable` type a "model").
- State holders are **named after their role, with no common suffix** (Swift API Design Guidelines: name things according to their roles):
  - when the role is a thing or a piece of state, a noun for it;
  - when the role is one job, a word for that job.
- What a state holder contains is told by its property names (`searcher.results`), not by its type name. Its place in the app target tells that it is a state holder.
- The region search state holder is `RegionSearcher`.

### Open

- How shared state is split into state holders (one or several) and their names.
- How features are injected (environment), including fakes for previews and tests.
- Where screen-scoped state holders are created and how long they live; debouncing the search (`.task(id:)` with `Task.sleep`, or `Observations` on a query property).
- Swift 6 settings for the app and widget targets (main actor default isolation, approachable concurrency).

## Considered options

**Where state lives**

- *A view model per screen (MVVM).* Each screen copies the shared data it shows into its own object, so the same data exists in several places and has to be kept in sync. Rejected for the single source of truth.
- *Views calling features directly*, keeping results in `@State`. Apple's MapKit sample (Interacting with nearby points of interest) does this for search completions. Rejected: views would hold I/O and its error handling, and the logic could not be tested without the view.
- *The search state holder in the `Region` feature package.* Rejected: it exists for one screen, and features do not know about screens.

**Naming**

- *`…ViewModel`*: implies MVVM. Most large apps surveyed use it (Wikipedia, WordPress, DuckDuckGo, Home Assistant, Signal), with one per screen.
- *`…Model`*: Apple's samples use it (`FoodTruckModel`, `MapModel`, `PlayerModel`), and so do Point-Free's SyncUps (`SyncUpDetailModel`) and Flutter's docs (`CartModel`). But Apple also calls plain data types "models" (`Book`), so the suffix does not tell a state holder from a data type.
- *`…Store`*: clashes with the features' role names (`RegionStore`).
- *`…State`*: Jetpack Compose's convention for state holders (`LazyListState`), but easy to confuse with SwiftUI's `@State`.
- *Named after the owning screen plus a suffix* (`SyncUpDetailModel`, `NewsViewModel`, `LazyListState`). This gives uniform names in designs with one state holder per screen; this app creates state holders per concern, not per screen.
- *Named after the state it holds* (`RegionSuggestions`). Says what the screen reads, but looks like a collection value type.

The surveyed code that does not use MVVM (Apple's recent samples, Ice Cubes) has no common suffix either. It names each state holder by what it is or does: `LocationFinder`, `ItineraryPlanner`, `LocationLookup`, `AccountStatusesFetcher`, `CurrentAccount`, `Library`.

## Consequences

- State holder names do not share a suffix, so they cannot be listed by name pattern. They are found by their place in the app target.
