// swift-tools-version: 6.2

import PackageDescription

let settings: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
  name: "PlaceSearch",
  platforms: [.iOS(.v26), .macOS(.v26), .watchOS(.v26)],
  products: [
    .library(name: "PlaceSearch", targets: ["PlaceSearch"]),
    .library(name: "PlaceSearchTesting", targets: ["PlaceSearchTesting"]),
  ],
  targets: [
    .target(name: "PlaceSearch", swiftSettings: settings),
    .target(
      name: "PlaceSearchTesting",
      dependencies: ["PlaceSearch"],
      swiftSettings: settings
    ),
    .testTarget(
      name: "PlaceSearchTests",
      dependencies: ["PlaceSearch", "PlaceSearchTesting"],
      swiftSettings: settings
    ),
  ]
)
