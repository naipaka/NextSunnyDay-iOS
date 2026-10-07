# 2. CI checks that every import is a declared dependency

- Status: Accepted (2026-10-07, #95)
- Builds on [0001](0001-modules-in-local-packages.md).

## Context

SwiftPM does not enforce declared dependencies. The compiler finds any module already built into the shared products directory, whether or not the importing target declares it. This has been an open bug since 2016, filed by SwiftPM's original author ([SR-1393 / apple/swift-issues#1393](https://github.com/apple/swift-issues/issues/1393)), and the [forum discussion](https://forums.swift.org/t/should-swiftpm-diagnose-missing-dependencies/70926) shows no fix as of 2025.

Tested locally (Swift 6.3.1, Xcode 26.4.1):

| Case | Result |
| --- | --- |
| Same package, target imports an undeclared sibling | Compiles, even after a clean build |
| … with `swift build --explicit-target-dependency-import-check=error` | Fails (exit 1) |
| Target imports a module it only gets transitively (C → B → A, C imports A) | Compiles, **even with the check flag** |
| Separate packages, P2 imports P1's module without declaring it, P2 built alone | Fails: `no such module` |
| Same, built together from a root package or `xcodebuild` | Fails on a clean build, **succeeds on the next incremental build** |

Xcode 26's explicitly built modules (on by default) did not prevent the last case.

The transitive case is the dangerous one: SwiftPM only rebuilds along declared edges, so a target that imports a module it never declared is not recompiled when that module changes. [swiftlang/swift-package-manager#10483](https://github.com/swiftlang/swift-package-manager/issues/10483) (2026) reports a silent miscompilation from this, with enum cases shifting to their neighbours. A real example of the gap: Ice Cubes' widget extension imports `DesignSystem` without linking it, getting it through `Timeline`.

This app's graph is shallow, but the setup should hold for deeper graphs in later apps.

## Decision

**Rule:** every module a target imports directly must be declared as its direct dependency, even if it is reachable transitively. This applies to package targets and to the Xcode targets (app, widget, tests).

**CI runs two checks; nothing runs locally by hook.** CI has to pass anyway, so that is where violations stop.

1. **Import check.** For every package, `swift package describe --type json` gives each target's direct dependencies and source files; every `import` of a repository module must be among them. For the Xcode targets, `project.pbxproj` gives each target's linked package products (`packageProductDependencies`) and synced folders, read with Foundation's `PropertyListSerialization`; their imports are checked the same way. This catches the transitive case and does not depend on the build system.
2. **Each package built and tested on its own** (`swift test` in the package folder). This backs up the import check (for example `@_exported import`) and runs the package's tests.

**The check is a Swift executable in its own tools package** (`swift run --package-path <tools> …`), Foundation only. It can be split into files, has Swift Testing tests, and can be copied to another app as one folder.

On pull requests, only changed packages and the packages that depend on them need testing; all packages after merging. The exact CI layout is part of #99.

## Considered options

- *Local hooks (Claude Code or git) running the same checks.* Faster feedback, but a cost on every edit or commit; rejected in favour of CI only.
- *`--explicit-target-dependency-import-check=error` alone.* Misses transitive imports, has no project-wide setting ([#7063](https://github.com/swiftlang/swift-package-manager/issues/7063)) and is not supported by the newer Swift Build backend ([#9620](https://github.com/swiftlang/swift-package-manager/issues/9620)).
- *Standalone package builds alone.* Miss transitive imports.
- *Third-party checkers (TargetDependencyChecker, SwiftImportChecks).* The repo has no third-party dependencies and the check is small.
- *A one-file script (`swift Scripts/….swift`).* Starts in about a second, but is harder to structure and test as it grows.
- *A SwiftPM command plugin.* A plugin runs in the context of one package; this check spans several packages and the Xcode project.

## Consequences

- On direct pushes to `main` the check reports after the fact; on pull requests it blocks the merge.
- The tool's build time on CI is not measured yet.
