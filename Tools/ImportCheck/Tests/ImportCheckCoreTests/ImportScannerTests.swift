import Testing

@testable import ImportCheckCore

struct ImportScannerTests {
  @Test func findsPlainAndDecoratedImports() {
    let source = """
      import Foundation
      @testable import Region
        @preconcurrency import Weather
      public import AppGroup
      @_exported import Forecast
      import struct SunnyDay.SunnyLevel
      import Units.Sub
      """
    #expect(
      ImportScanner.imports(in: source).map(\.module) == [
        "Foundation", "Region", "Weather", "AppGroup", "Forecast", "SunnyDay", "Units",
      ])
  }

  @Test func reportsOneBasedLines() {
    let source = "// header\n\nimport Weather\n"
    #expect(ImportScanner.imports(in: source) == [.init(module: "Weather", line: 3)])
  }

  @Test func skipsComments() {
    let source = """
      // import Region
      /* import Forecast */ import Weather
      /*
      import AppGroup
      */
      let important = 1
      """
    #expect(ImportScanner.imports(in: source).map(\.module) == ["Weather"])
  }
}
