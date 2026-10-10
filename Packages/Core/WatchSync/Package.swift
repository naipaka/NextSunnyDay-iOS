// swift-tools-version: 6.2

import PackageDescription

let settings: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
  name: "WatchSync",
  platforms: [.iOS(.v26), .macOS(.v26), .watchOS(.v26)],
  products: [
    .library(name: "WatchSync", targets: ["WatchSync"])
  ],
  targets: [
    .target(name: "WatchSync", swiftSettings: settings),
    .testTarget(
      name: "WatchSyncTests",
      dependencies: ["WatchSync"],
      swiftSettings: settings
    ),
  ]
)
