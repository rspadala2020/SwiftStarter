import Foundation
import Testing
@testable import SwiftStarter

@MainActor
struct TaskStoreSwiftTests {
    @Test("Intentional failure: blank title is wrongly expected to be added")
    func intentionallyFailingSwiftTest() throws {
        try withIsolatedDefaults { defaults in
            let store = TaskStore(defaults: defaults)

            store.add("   ")

            #expect(store.tasks.count == 1)
        }
    }

    @Test("Adding tasks trims titles and ignores blank input")
    func addingTasksValidatesTitles() throws {
        try withIsolatedDefaults { defaults in
            let store = TaskStore(defaults: defaults)

            store.add("  Buy milk \n")
            store.add(" \n\t ")

            #expect(store.tasks.count == 1)
            let task = try #require(store.tasks.first)
            #expect(task.title == "Buy milk")
            #expect(!task.isComplete)
            #expect(store.errorMessage == nil)
        }
    }

    @Test("Completion and task identity survive reloading")
    func completionPersistsAcrossReloads() throws {
        try withIsolatedDefaults { defaults in
            let store = TaskStore(defaults: defaults)
            store.add("Read a chapter")
            let task = try #require(store.tasks.first)

            store.toggle(task.id)

            let reloaded = TaskStore(defaults: defaults)
            #expect(reloaded.tasks.count == 1)
            let restored = try #require(reloaded.tasks.first)
            #expect(restored.id == task.id)
            #expect(restored.title == task.title)
            #expect(restored.isComplete)

            reloaded.toggle(restored.id)
            let reopened = TaskStore(defaults: defaults)
            #expect(try #require(reopened.tasks.first).isComplete == false)
        }
    }

    private func withIsolatedDefaults(_ body: (UserDefaults) throws -> Void) throws {
        let suiteName = "SwiftStarter.SwiftTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        try body(defaults)
    }
}
