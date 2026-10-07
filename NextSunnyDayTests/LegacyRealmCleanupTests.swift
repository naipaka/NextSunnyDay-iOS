//
//  LegacyRealmCleanupTests.swift
//  NextSunnyDayTests
//

import Foundation
import Testing

@testable import NextSunnyDay

final class LegacyRealmCleanupTests {
  private let directory = FileManager.default.temporaryDirectory
    .appending(path: "LegacyRealmCleanupTests-\(UUID().uuidString)", directoryHint: .isDirectory)

  deinit {
    try? FileManager.default.removeItem(at: directory)
  }

  private func contents() throws -> Set<String> {
    Set(try FileManager.default.contentsOfDirectory(atPath: directory.path(percentEncoded: false)))
  }

  @Test func removesTheRealmFilesAndKeepsTheRest() throws {
    let fileManager = FileManager.default
    try fileManager.createDirectory(
      at: directory.appending(path: "db.realm.management"), withIntermediateDirectories: true)
    try fileManager.createDirectory(
      at: directory.appending(path: "Library/Caches"), withIntermediateDirectories: true)
    for name in ["db.realm", "db.realm.lock", "db.realm.note", "db.realm.management/access"] {
      try Data().write(to: directory.appending(path: name))
    }

    LegacyRealmCleanup.run(in: directory)

    #expect(try contents() == ["Library"])
  }

  @Test func doesNothingWithoutRealmFiles() throws {
    try FileManager.default.createDirectory(
      at: directory.appending(path: "Library"), withIntermediateDirectories: true)
    LegacyRealmCleanup.run(in: directory)
    #expect(try contents() == ["Library"])
  }

  @Test func toleratesAMissingDirectory() {
    LegacyRealmCleanup.run(in: directory)
  }
}
