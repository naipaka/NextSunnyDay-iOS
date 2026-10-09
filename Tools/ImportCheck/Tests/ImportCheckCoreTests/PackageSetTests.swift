import Foundation
import Testing

@testable import ImportCheckCore

struct PackageSetTests {
  let weather = DescribedPackage(
    name: "Weather",
    path: "/repo/Packages/Core/Weather",
    products: [
      .init(name: "Weather", targets: ["Weather"]),
      .init(name: "WeatherTesting", targets: ["WeatherTesting"]),
    ],
    targets: [
      .init(
        name: "Weather", path: "Sources/Weather", type: "library", sources: ["A.swift"],
        targetDependencies: nil, productDependencies: nil),
      .init(
        name: "WeatherTesting", path: "Sources/WeatherTesting", type: "library",
        sources: ["Fake.swift", "Recording.json"], targetDependencies: ["Weather"],
        productDependencies: nil),
      .init(
        name: "WeatherTests", path: "Tests/WeatherTests", type: "test", sources: ["T.swift"],
        targetDependencies: ["Weather", "WeatherTesting"], productDependencies: nil),
    ]
  )

  @Test func decodesTheDescribeOutput() throws {
    let json = """
      {
        "name" : "Forecast",
        "path" : "/repo/Packages/Features/Forecast",
        "products" : [{ "name" : "Forecast", "targets" : ["Forecast"], "type" : { "library" : ["automatic"] } }],
        "targets" : [{
          "name" : "Forecast",
          "path" : "Sources/Forecast",
          "type" : "library",
          "sources" : ["ForecastCache.swift"],
          "product_dependencies" : ["Weather", "AppGroup"]
        }]
      }
      """
    let package = try DescribedPackage.decode(Data(json.utf8))

    #expect(package.name == "Forecast")
    #expect(package.targets.first?.productDependencies == ["Weather", "AppGroup"])
    #expect(package.targets.first?.targetDependencies == nil)
  }

  @Test func modulesLeaveOutTestTargets() {
    #expect(PackageSet([weather]).modules == ["Weather", "WeatherTesting"])
  }

  @Test func sourceTargetsListSwiftFilesAndDeclaredModules() {
    let forecast = DescribedPackage(
      name: "Forecast",
      path: "/repo/Packages/Features/Forecast",
      products: [.init(name: "Forecast", targets: ["Forecast"])],
      targets: [
        .init(
          name: "ForecastTests", path: "Tests/ForecastTests", type: "test",
          sources: ["T.swift"], targetDependencies: ["Forecast"],
          productDependencies: ["WeatherTesting"])
      ]
    )
    let targets = PackageSet([weather, forecast]).sourceTargets

    let testing = targets.first { $0.name == "WeatherTesting" }
    #expect(
      testing?.files.map(\.path) == [
        "/repo/Packages/Core/Weather/Sources/WeatherTesting/Fake.swift"
      ])
    let tests = targets.first { $0.name == "ForecastTests" }
    #expect(tests?.declaredModules == ["Forecast", "WeatherTesting"])
  }

  @Test func findsPackageDirectoriesButNotNestedBuildFolders() throws {
    let root = try temporaryFolder()
    for path in ["Core/A", "Core/A/.build/checkouts/X", "Features/B"] {
      let folder = root.appending(path: path)
      try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
      try "".write(to: folder.appending(path: "Package.swift"), atomically: true, encoding: .utf8)
    }

    #expect(
      PackageSet.packageDirectories(under: root).map(\.lastPathComponent) == ["A", "B"])
  }
}
