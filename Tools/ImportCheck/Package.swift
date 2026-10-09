// swift-tools-version: 6.2

import PackageDescription

let settings: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
  name: "ImportCheck",
  platforms: [.macOS(.v26)],
  products: [
    .executable(name: "import-check", targets: ["import-check"])
  ],
  targets: [
    .target(name: "ImportCheckCore", swiftSettings: settings),
    .executableTarget(
      name: "import-check",
      dependencies: ["ImportCheckCore"],
      swiftSettings: settings
    ),
    .testTarget(
      name: "ImportCheckCoreTests",
      dependencies: ["ImportCheckCore"],
      swiftSettings: settings
    ),
  ]
)
