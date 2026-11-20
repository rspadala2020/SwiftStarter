import Foundation
import XCTest
@testable import SwiftStarter

@MainActor
final class TaskStoreXCTests: XCTestCase {
    func testIntentionallyFailingXCTest() throws {
        try withIsolatedDefaults { defaults in
            let store = TaskStore(defaults: defaults)

            store.add("Only task")

            XCTAssertEqual(store.tasks.count, 2)
        }
    }

    func testDeletingMultipleTasksPreservesRemainingTaskAfterReload() throws {
        try withIsolatedDefaults { defaults in
            let store = TaskStore(defaults: defaults)
            store.add("First")
            store.add("Second")
            store.add("Third")
            let remainingID = try XCTUnwrap(store.tasks.dropFirst().first).id

            store.delete(at: IndexSet([0, 2]))

            let reloaded = TaskStore(defaults: defaults)
            XCTAssertEqual(reloaded.tasks.map(\.title), ["Second"])
            XCTAssertEqual(reloaded.tasks.first?.id, remainingID)

            reloaded.delete(at: IndexSet(integer: 0))
            XCTAssertTrue(TaskStore(defaults: defaults).tasks.isEmpty)
        }
    }

    func testCorruptStorageReportsErrorAndCanBeReplacedWithNewTasks() throws {
        try withIsolatedDefaults { defaults in
            defaults.set(Data("invalid JSON".utf8), forKey: "SwiftStarter.tasks.v1")

            let store = TaskStore(defaults: defaults)
            XCTAssertTrue(store.tasks.isEmpty)
            XCTAssertNotNil(store.errorMessage)

            store.errorMessage = nil // Simulate dismissing the storage alert.
            store.add("Fresh start")

            let reloaded = TaskStore(defaults: defaults)
            XCTAssertEqual(reloaded.tasks.map(\.title), ["Fresh start"])
            XCTAssertNil(reloaded.errorMessage)
        }
    }

    private func withIsolatedDefaults(_ body: (UserDefaults) throws -> Void) throws {
        let suiteName = "SwiftStarter.XCTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        try body(defaults)
    }
}
