// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "AppGroup",
  platforms: [.iOS(.v26), .macOS(.v26)],
  products: [
    .library(name: "AppGroup", targets: ["AppGroup"])
  ],
  targets: [
    .target(
      name: "AppGroup",
      swiftSettings: [
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("MemberImportVisibility"),
      ]
    ),
    .testTarget(name: "AppGroupTests", dependencies: ["AppGroup"]),
  ]
)
