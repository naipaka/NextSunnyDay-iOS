import Foundation
import Testing

@testable import ImportCheckCore

struct ImportCheckerTests {
  @Test func reportsUndeclaredRepositoryModules() throws {
    let folder = try temporaryFolder()
    let file = folder.appending(path: "A.swift")
    try """
    import Foundation
    import Forecast
    import Weather
    import AppGroup
    @testable import App
    """.write(to: file, atomically: true, encoding: .utf8)
    let target = SourceTarget(
      owner: "Forecast", name: "ForecastTests", files: [file], declaredModules: ["Forecast"])

    let violations = try ImportChecker.violations(
      in: [target], repositoryModules: ["Forecast", "Weather", "AppGroup"])

    #expect(
      violations == [
        Violation(file: file, line: 3, target: "ForecastTests", module: "Weather"),
        Violation(file: file, line: 4, target: "ForecastTests", module: "AppGroup"),
      ])
  }

  @Test func allowsATargetsOwnModule() throws {
    let folder = try temporaryFolder()
    let file = folder.appending(path: "A.swift")
    try "import Weather\n".write(to: file, atomically: true, encoding: .utf8)
    let target = SourceTarget(owner: "Weather", name: "Weather", files: [file], declaredModules: [])

    #expect(try ImportChecker.violations(in: [target], repositoryModules: ["Weather"]).isEmpty)
  }
}

func temporaryFolder() throws -> URL {
  let url = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
  try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
  return url
}
