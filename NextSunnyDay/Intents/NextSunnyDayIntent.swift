import AppIntents
import Foundation
import RegionIntents
import SwiftUI
import Units

/// Includes `RegionEntity` from the `RegionIntents` module, which the widget uses too.
struct NextSunnyDayIntentsPackage: AppIntentsPackage {
  static var includedPackages: [any AppIntentsPackage.Type] { [RegionIntentsPackage.self] }
}

/// Answers 「次いつ晴れる？」 for a saved region, with a spoken dialog and a snippet.
struct NextSunnyDayIntent: AppIntent {
  static let title: LocalizedStringResource = "Next Sunny Day"
  static let description = IntentDescription("See when the next sunny day is.")

  /// Left empty, the first region in the app's list.
  @Parameter(title: "Region")
  var region: RegionEntity?

  @Dependency private var features: AppFeatures

  static var parameterSummary: some ParameterSummary {
    Summary("Next sunny day in \(\.$region)")
  }

  @MainActor
  func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
    let answer = await features.nextSunnyDayAnswer(regionID: region?.id)
    let unit = features.temperatureUnitStore.load().unit(for: .current)
    return .result(
      dialog: IntentDialog(answer.dialog),
      view: SunnyDaySnippet(answer: answer, temperatureUnit: unit))
  }
}

/// The phrases for Siri, and the shortcut shown in Spotlight and the Shortcuts app. The Japanese
/// phrases are in `AppShortcuts.xcstrings`. Each phrase asks the app to do something: a phrase that
/// reads as a weather question, such as the app's name 「次いつ晴れる？」 alone, is answered by
/// Siri's own weather instead (ADR 0008).
struct NextSunnyDayShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: NextSunnyDayIntent(),
      phrases: [
        "Check \(.applicationName)",
        "Check \(.applicationName) for \(\.$region)",
        "Ask \(.applicationName)",
      ],
      shortTitle: "Next Sunny Day",
      systemImageName: "sun.max"
    )
  }
}
