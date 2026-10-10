// swift-tools-version: 6.2

import PackageDescription

let settings: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
  name: "Units",
  platforms: [.iOS(.v26), .macOS(.v26), .watchOS(.v26)],
  products: [
    .library(name: "Units", targets: ["Units"])
  ],
  dependencies: [
    .package(path: "../../Core/AppGroup")
  ],
  targets: [
    .target(
      name: "Units",
      dependencies: [
        .product(name: "AppGroup", package: "AppGroup")
      ],
      swiftSettings: settings
    ),
    .testTarget(
      name: "UnitsTests",
      dependencies: ["Units"],
      swiftSettings: settings
    ),
  ]
)
