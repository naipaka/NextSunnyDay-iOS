// swift-tools-version: 6.2

import PackageDescription

let settings: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
  name: "Region",
  platforms: [.iOS(.v26), .macOS(.v26)],
  products: [
    .library(name: "Region", targets: ["Region"])
  ],
  dependencies: [
    .package(path: "../../Core/Location"),
    .package(path: "../../Core/PlaceSearch"),
    .package(path: "../../Core/AppGroup"),
  ],
  targets: [
    .target(
      name: "Region",
      dependencies: [
        .product(name: "Location", package: "Location"),
        .product(name: "PlaceSearch", package: "PlaceSearch"),
        .product(name: "AppGroup", package: "AppGroup"),
      ],
      swiftSettings: settings
    ),
    .testTarget(
      name: "RegionTests",
      dependencies: [
        "Region",
        .product(name: "Location", package: "Location"),
        .product(name: "LocationTesting", package: "Location"),
        .product(name: "PlaceSearch", package: "PlaceSearch"),
        .product(name: "PlaceSearchTesting", package: "PlaceSearch"),
      ],
      swiftSettings: settings
    ),
  ]
)
