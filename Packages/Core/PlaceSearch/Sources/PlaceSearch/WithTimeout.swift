/// The result of `operation`, or `nil` if `timeout` passes first, which cancels it.
func withTimeout<T: Sendable>(
  _ timeout: Duration, operation: @escaping @Sendable () async throws -> T?
) async throws -> T? {
  try await withThrowingTaskGroup(of: T?.self) { group in
    group.addTask { try await operation() }
    group.addTask {
      try await Task.sleep(for: timeout)
      return nil
    }
    let first = try await group.next() ?? nil
    group.cancelAll()
    return first
  }
}
