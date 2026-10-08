// swift-tools-version: 6.2

import PackageDescription

let settings: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
  name: "Forecast",
  platforms: [.iOS(.v26), .macOS(.v26)],
  products: [
    .library(name: "Forecast", targets: ["Forecast"])
  ],
  dependencies: [
    .package(path: "../../Core/Weather"),
    .package(path: "../../Core/AppGroup"),
  ],
  targets: [
    .target(
      name: "Forecast",
      dependencies: [
        .product(name: "Weather", package: "Weather"),
        .product(name: "AppGroup", package: "AppGroup"),
      ],
      swiftSettings: settings
    ),
    .testTarget(
      name: "ForecastTests",
      dependencies: [
        "Forecast",
        .product(name: "Weather", package: "Weather"),
        .product(name: "WeatherTesting", package: "Weather"),
      ],
      swiftSettings: settings
    ),
  ]
)
