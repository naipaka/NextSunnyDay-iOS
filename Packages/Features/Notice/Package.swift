// swift-tools-version: 6.2

import PackageDescription

let settings: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
  name: "Notice",
  platforms: [.iOS(.v26), .macOS(.v26)],
  products: [
    .library(name: "Notice", targets: ["Notice"])
  ],
  dependencies: [
    .package(path: "../../Core/Weather"),
    .package(path: "../../Core/Notifications"),
    .package(path: "../../Core/AppGroup"),
  ],
  targets: [
    .target(
      name: "Notice",
      dependencies: [
        .product(name: "Weather", package: "Weather"),
        .product(name: "Notifications", package: "Notifications"),
        .product(name: "AppGroup", package: "AppGroup"),
      ],
      swiftSettings: settings
    ),
    .testTarget(
      name: "NoticeTests",
      dependencies: [
        "Notice",
        .product(name: "Weather", package: "Weather"),
        .product(name: "Notifications", package: "Notifications"),
        .product(name: "NotificationsTesting", package: "Notifications"),
      ],
      swiftSettings: settings
    ),
  ]
)
