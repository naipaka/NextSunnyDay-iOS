// DeclaredAgeRange isn't annotated for Sendable yet; its service and action are used here only.
@preconcurrency import DeclaredAgeRange

/// Age assurance where a law requires it, such as Texas's App Store Accountability Act: the app
/// checks the person's age category with the App Store. The app is the same at every age, so it
/// restricts nothing and doesn't keep the answer.
enum AgeAssurance {
  /// Asks for the age range when the person's region and account require it, and does nothing
  /// anywhere else. Earlier versions than iOS 26.4 don't report the requirements.
  static func verify(using requestAgeRange: DeclaredAgeRangeAction) async {
    guard #available(iOS 26.4, *),
      let features = try? await AgeRangeService.shared.requiredRegulatoryFeatures,
      features.contains(.declaredAgeRangeRequired)
    else { return }
    // The age categories of the law: under 13, 13–15, 16–17 and 18 or over.
    _ = try? await requestAgeRange(ageGates: 13, 16, 18)
  }
}
