// swift-tools-version: 6.2

import PackageDescription

let settings: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
  name: "Location",
  platforms: [.iOS(.v26), .macOS(.v26)],
  products: [
    .library(name: "Location", targets: ["Location"]),
    .library(name: "LocationTesting", targets: ["LocationTesting"]),
  ],
  targets: [
    .target(name: "Location", swiftSettings: settings),
    .target(
      name: "LocationTesting",
      dependencies: ["Location"],
      swiftSettings: settings
    ),
    .testTarget(
      name: "LocationTests",
      dependencies: ["Location", "LocationTesting"],
      swiftSettings: settings
    ),
  ]
)
