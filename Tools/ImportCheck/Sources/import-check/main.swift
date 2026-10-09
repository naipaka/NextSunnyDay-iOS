import Foundation
import ImportCheckCore

// Usage: import-check [repository root]
//
// Checks that every import of a module from Packages/ is declared as a direct
// dependency of the importing target, in the packages and in the Xcode project
// (docs/architecture/decisions/0002-dependency-checks-in-ci.md).

let root = URL(
  filePath: CommandLine.arguments.dropFirst().first ?? FileManager.default.currentDirectoryPath,
  directoryHint: .isDirectory
)

do {
  let packages = PackageSet(
    try PackageSet.packageDirectories(under: root.appending(path: "Packages"))
      .map(DescribedPackage.describe))
  let projects = try FileManager.default.contentsOfDirectory(atPath: root.path)
    .filter { $0.hasSuffix(".xcodeproj") }
    .sorted()
  var targets = packages.sourceTargets
  for project in projects {
    targets += try XcodeProject.targets(
      projectFile: root.appending(path: project).appending(path: "project.pbxproj"),
      sourceRoot: root,
      modulesOfProduct: packages.modules(ofProduct:)
    )
  }
  let violations = try ImportChecker.violations(
    in: targets, repositoryModules: packages.modules)
  for violation in violations {
    print(violation.description.replacingOccurrences(of: root.path + "/", with: ""))
  }
  if !violations.isEmpty {
    exit(1)
  }
  print(
    "Imports match the declared dependencies: \(targets.count) targets in "
      + "\(packages.packages.count) packages and \(projects.count) Xcode project(s)."
  )
} catch {
  print("error: \(error)")
  exit(1)
}
