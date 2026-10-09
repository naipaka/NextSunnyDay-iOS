import Foundation
import Testing

@testable import ImportCheckCore

struct XcodeProjectTests {
  /// An app and a widget with a synchronized folder each. The app's Info.plist and
  /// Old.swift are excluded from it; the widget also builds Shared/Format.swift
  /// from the app's folder.
  let project = """
    // !$*UTF8*$!
    {
      objects = {
        APP = {
          isa = PBXNativeTarget;
          name = App;
          fileSystemSynchronizedGroups = (APPGROUP);
          packageProductDependencies = (P1, P2);
        };
        WIDGET = {
          isa = PBXNativeTarget;
          name = Widget;
          fileSystemSynchronizedGroups = (WIDGETGROUP);
          packageProductDependencies = (P3);
        };
        APPGROUP = {
          isa = PBXFileSystemSynchronizedRootGroup;
          path = App;
          exceptions = (APPEXCEPTIONS, WIDGETEXCEPTIONS);
        };
        WIDGETGROUP = {
          isa = PBXFileSystemSynchronizedRootGroup;
          path = Widget;
        };
        APPEXCEPTIONS = {
          isa = PBXFileSystemSynchronizedBuildFileExceptionSet;
          membershipExceptions = (Info.plist, Old.swift);
          target = APP;
        };
        WIDGETEXCEPTIONS = {
          isa = PBXFileSystemSynchronizedBuildFileExceptionSet;
          membershipExceptions = (Shared);
          target = WIDGET;
        };
        P1 = { isa = XCSwiftPackageProductDependency; productName = Region; };
        P2 = { isa = XCSwiftPackageProductDependency; productName = WeatherTesting; };
        P3 = { isa = XCSwiftPackageProductDependency; productName = Forecast; };
      };
    }
    """

  @Test func readsFilesAndProductsOfEachTarget() throws {
    let root = try temporaryFolder()
    for path in ["App/AppMain.swift", "App/Old.swift", "App/Shared/Format.swift", "Widget/W.swift"]
    {
      let file = root.appending(path: path)
      try FileManager.default.createDirectory(
        at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
      try "".write(to: file, atomically: true, encoding: .utf8)
    }
    let projectFile = root.appending(path: "project.pbxproj")
    try project.write(to: projectFile, atomically: true, encoding: .utf8)

    let targets = try XcodeProject.targets(
      projectFile: projectFile, sourceRoot: root, modulesOfProduct: { [$0] })

    #expect(targets.map(\.name) == ["App", "Widget"])
    #expect(
      targets[0].files.map { $0.path.replacingOccurrences(of: root.path + "/", with: "") } == [
        "App/AppMain.swift", "App/Shared/Format.swift",
      ])
    #expect(targets[0].declaredModules == ["Region", "WeatherTesting"])
    #expect(
      targets[1].files.map { $0.path.replacingOccurrences(of: root.path + "/", with: "") } == [
        "App/Shared/Format.swift", "Widget/W.swift",
      ])
    #expect(targets[1].declaredModules == ["Forecast"])
  }
}
