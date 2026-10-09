import Foundation

/// The part of `swift package describe --type json` that the check reads.
public struct DescribedPackage: Decodable, Equatable, Sendable {
  public struct Product: Decodable, Equatable, Sendable {
    public var name: String
    public var targets: [String]
  }

  public struct Target: Decodable, Equatable, Sendable {
    public var name: String
    public var path: String
    public var type: String
    public var sources: [String]
    public var targetDependencies: [String]?
    public var productDependencies: [String]?

    enum CodingKeys: String, CodingKey {
      case name, path, type, sources
      case targetDependencies = "target_dependencies"
      case productDependencies = "product_dependencies"
    }
  }

  public var name: String
  public var path: String
  public var products: [Product]
  public var targets: [Target]

  public static func decode(_ data: Data) throws -> DescribedPackage {
    try JSONDecoder().decode(DescribedPackage.self, from: data)
  }

  /// Runs `swift package describe` in `directory`.
  public static func describe(_ directory: URL) throws -> DescribedPackage {
    let process = Process()
    process.executableURL = URL(filePath: "/usr/bin/env")
    process.arguments = ["swift", "package", "describe", "--type", "json"]
    process.currentDirectoryURL = directory
    let output = Pipe()
    process.standardOutput = output
    try process.run()
    let data = output.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else {
      throw CheckError("swift package describe failed in \(directory.path)")
    }
    return try decode(data)
  }
}

/// The local packages of the repository.
public struct PackageSet: Sendable {
  public var packages: [DescribedPackage]

  public init(_ packages: [DescribedPackage]) {
    self.packages = packages
  }

  /// Every module a package defines, except test targets.
  public var modules: Set<String> {
    Set(packages.flatMap { $0.targets.filter { $0.type != "test" }.map(\.name) })
  }

  /// The modules a product of any of the packages contains.
  public func modules(ofProduct name: String) -> Set<String> {
    Set(packages.flatMap { $0.products.filter { $0.name == name }.flatMap(\.targets) })
  }

  /// Every target of every package, with the modules it declares.
  public var sourceTargets: [SourceTarget] {
    packages.flatMap { package in
      package.targets.map { target in
        let directory = URL(filePath: package.path).appending(path: target.path)
        let fromProducts = (target.productDependencies ?? []).flatMap { modules(ofProduct: $0) }
        return SourceTarget(
          owner: package.name,
          name: target.name,
          files: target.sources.filter { $0.hasSuffix(".swift") }.map {
            directory.appending(path: $0)
          },
          declaredModules: Set(target.targetDependencies ?? []).union(fromProducts)
        )
      }
    }
  }

  /// The directories under `root` that hold a `Package.swift`, skipping build folders.
  public static func packageDirectories(under root: URL) -> [URL] {
    guard
      let enumerator = FileManager.default.enumerator(
        at: root, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
    else { return [] }
    var result: [URL] = []
    for case let url as URL in enumerator where url.lastPathComponent == "Package.swift" {
      result.append(url.deletingLastPathComponent())
      enumerator.skipDescendants()
    }
    return result.sorted { $0.path < $1.path }
  }
}

public struct CheckError: Error, CustomStringConvertible {
  public var description: String

  public init(_ description: String) {
    self.description = description
  }
}
