import Foundation

/// The Xcode targets of a project that uses folder-synchronized groups.
public enum XcodeProject {
  /// Reads the native targets of `projectFile` (`project.pbxproj`): the Swift files
  /// of their synchronized folders, after the membership exceptions, and the
  /// modules of their linked package products. Folder paths are relative to
  /// `sourceRoot`.
  public static func targets(
    projectFile: URL, sourceRoot: URL, modulesOfProduct: (String) -> Set<String>
  ) throws -> [SourceTarget] {
    let data = try Data(contentsOf: projectFile)
    guard
      let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
        as? [String: Any],
      let objects = plist["objects"] as? [String: [String: Any]]
    else { throw CheckError("Can't read \(projectFile.path)") }

    let nativeTargets = objects.filter { $0.value["isa"] as? String == "PBXNativeTarget" }
    let groups = objects.filter {
      $0.value["isa"] as? String == "PBXFileSystemSynchronizedRootGroup"
    }

    return try nativeTargets.map { id, target in
      let name = target["name"] as? String ?? id
      let ownGroups = Set(target["fileSystemSynchronizedGroups"] as? [String] ?? [])
      var files: [URL] = []
      for (groupID, group) in groups {
        guard let path = group["path"] as? String else { continue }
        let exceptions = (group["exceptions"] as? [String] ?? [])
          .compactMap { objects[$0] }
          .filter { $0["target"] as? String == id }
          .flatMap { $0["membershipExceptions"] as? [String] ?? [] }
        let folder = sourceRoot.appending(path: path)
        for relative in try swiftFiles(in: folder) {
          let listed = exceptions.contains { relative == $0 || relative.hasPrefix($0 + "/") }
          // An exception removes a file from a folder of the target, and adds a
          // file of another target's folder.
          if ownGroups.contains(groupID) != listed {
            files.append(folder.appending(path: relative))
          }
        }
      }
      let products = (target["packageProductDependencies"] as? [String] ?? [])
        .compactMap { objects[$0]?["productName"] as? String }
      return SourceTarget(
        owner: projectFile.deletingLastPathComponent().lastPathComponent,
        name: name,
        files: files.sorted { $0.path < $1.path },
        declaredModules: Set(products.flatMap(modulesOfProduct))
      )
    }
    .sorted { $0.name < $1.name }
  }

  /// The paths of the Swift files under `folder`, relative to it.
  static func swiftFiles(in folder: URL) throws -> [String] {
    let paths = try FileManager.default.subpathsOfDirectory(atPath: folder.path)
    return paths.filter { $0.hasSuffix(".swift") }.sorted()
  }
}
