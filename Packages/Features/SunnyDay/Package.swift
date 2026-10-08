// swift-tools-version: 6.2

import PackageDescription

let settings: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
  name: "SunnyDay",
  platforms: [.iOS(.v26), .macOS(.v26)],
  products: [
    .library(name: "SunnyDay", targets: ["SunnyDay"])
  ],
  dependencies: [
    .package(path: "../../Core/Weather"),
    .package(path: "../../Core/AppGroup"),
  ],
  targets: [
    .target(
      name: "SunnyDay",
      dependencies: [
        .product(name: "Weather", package: "Weather"),
        .product(name: "AppGroup", package: "AppGroup"),
      ],
      swiftSettings: settings
    ),
    .testTarget(
      name: "SunnyDayTests",
      dependencies: [
        "SunnyDay",
        .product(name: "Weather", package: "Weather"),
        .product(name: "WeatherTesting", package: "Weather"),
      ],
      swiftSettings: settings
    ),
  ]
)
