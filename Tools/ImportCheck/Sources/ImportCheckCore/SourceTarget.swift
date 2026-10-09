import Foundation

/// A target's Swift files and the modules it declares as direct dependencies.
public struct SourceTarget: Equatable, Sendable {
  /// Where the target is defined, such as a package name or the Xcode project.
  public var owner: String
  public var name: String
  public var files: [URL]
  public var declaredModules: Set<String>

  public init(owner: String, name: String, files: [URL], declaredModules: Set<String>) {
    self.owner = owner
    self.name = name
    self.files = files
    self.declaredModules = declaredModules
  }
}

/// An import of a repository module that its target doesn't declare.
public struct Violation: Equatable, Sendable, CustomStringConvertible {
  public var file: URL
  public var line: Int
  public var target: String
  public var module: String

  public init(file: URL, line: Int, target: String, module: String) {
    self.file = file
    self.line = line
    self.target = target
    self.module = module
  }

  public var description: String {
    "\(file.path):\(line): error: \(target) imports \(module) but doesn't declare it as a dependency"
  }
}

public enum ImportChecker {
  /// The imports in `targets` of a module in `repositoryModules` that the
  /// importing target doesn't declare. Other modules (system frameworks, the
  /// app module in `@testable import`) are not checked.
  public static func violations(
    in targets: [SourceTarget], repositoryModules: Set<String>
  ) throws -> [Violation] {
    var result: [Violation] = []
    for target in targets {
      for file in target.files {
        let source = try String(contentsOf: file, encoding: .utf8)
        for found in ImportScanner.imports(in: source)
        where repositoryModules.contains(found.module)
          && found.module != target.name
          && !target.declaredModules.contains(found.module)
        {
          result.append(
            Violation(file: file, line: found.line, target: target.name, module: found.module))
        }
      }
    }
    return result
  }
}
