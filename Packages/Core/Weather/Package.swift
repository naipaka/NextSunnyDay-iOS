// swift-tools-version: 6.2

import PackageDescription

let settings: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
  name: "Weather",
  platforms: [.iOS(.v26), .macOS(.v26)],
  products: [
    .library(name: "Weather", targets: ["Weather"]),
    .library(name: "WeatherTesting", targets: ["WeatherTesting"]),
  ],
  targets: [
    .target(name: "Weather", swiftSettings: settings),
    .target(
      name: "WeatherTesting",
      dependencies: ["Weather"],
      resources: [.copy("Recordings")],
      swiftSettings: settings
    ),
    .testTarget(
      name: "WeatherTests",
      dependencies: ["Weather", "WeatherTesting"],
      swiftSettings: settings
    ),
  ]
)
