/// Finds the modules a Swift source file imports.
public enum ImportScanner {
  public struct Import: Equatable, Sendable {
    public var module: String
    public var line: Int

    public init(module: String, line: Int) {
      self.module = module
      self.line = line
    }
  }

  /// The imports in `source`, with their 1-based line numbers. Covers attributes
  /// (`@testable`, `@_exported`, `@preconcurrency`), access levels and kinds
  /// (`import struct Foo.Bar`); skips comments.
  public static func imports(in source: String) -> [Import] {
    let pattern =
      /^\s*(?:@\w+(?:\([^)]*\))?\s+)*(?:(?:public|package|internal|fileprivate|private)\s+)?import\s+(?:(?:typealias|struct|class|enum|protocol|let|var|func)\s+)?(\w+)/
    var result: [Import] = []
    var inBlockComment = false
    for (index, rawLine) in source.split(separator: "\n", omittingEmptySubsequences: false)
      .enumerated()
    {
      var line = ""
      var rest = Substring(rawLine)
      // Keep only the code outside block comments.
      while !rest.isEmpty {
        if inBlockComment {
          guard let end = rest.firstRange(of: "*/") else { break }
          rest = rest[end.upperBound...]
          inBlockComment = false
        } else if let start = rest.firstRange(of: "/*") {
          line += rest[..<start.lowerBound]
          rest = rest[start.upperBound...]
          inBlockComment = true
        } else {
          line += rest
          break
        }
      }
      if let match = line.prefixMatch(of: pattern) {
        result.append(Import(module: String(match.1), line: index + 1))
      }
    }
    return result
  }
}
