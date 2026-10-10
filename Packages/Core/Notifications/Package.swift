// swift-tools-version: 6.2

import PackageDescription

let settings: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
  name: "Notifications",
  platforms: [.iOS(.v26), .macOS(.v26)],
  products: [
    .library(name: "Notifications", targets: ["Notifications"]),
    .library(name: "NotificationsTesting", targets: ["NotificationsTesting"]),
  ],
  targets: [
    .target(name: "Notifications", swiftSettings: settings),
    .target(
      name: "NotificationsTesting",
      dependencies: ["Notifications"],
      swiftSettings: settings
    ),
    .testTarget(
      name: "NotificationsTests",
      dependencies: ["Notifications", "NotificationsTesting"],
      swiftSettings: settings
    ),
  ]
)
