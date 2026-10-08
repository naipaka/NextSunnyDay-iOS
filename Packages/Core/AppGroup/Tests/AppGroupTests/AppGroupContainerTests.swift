import AppGroup
import Testing

struct AppGroupContainerTests {
  /// Must match the entitlements of the app and the widget. Changing it would leave the stored
  /// settings and caches behind in the old container.
  @Test func identifierMatchesTheEntitlements() {
    #expect(AppGroupContainer.identifier == "group.com.naipaka.NextSunnyDay")
  }
}
