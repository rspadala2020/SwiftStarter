import Foundation
import Observation

struct TaskItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isComplete: Bool

    init(title: String) {
        id = UUID()
        self.title = title
        isComplete = false
    }
}

@MainActor
@Observable
final class TaskStore {
    private(set) var tasks: [TaskItem]
    var errorMessage: String?

    private let defaults: UserDefaults
    private let storageKey = "SwiftStarter.tasks.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        tasks = []
        guard let data = defaults.data(forKey: storageKey) else { return }
        do {
            tasks = try JSONDecoder().decode([TaskItem].self, from: data)
        } catch {
            errorMessage = "Saved tasks could not be loaded. Adding a task will start a new list."
        }
    }

    func add(_ title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        tasks.append(TaskItem(title: trimmedTitle))
        save()
    }

    func toggle(_ id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isComplete.toggle()
        save()
    }

    func delete(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            tasks.remove(at: index)
        }
        save()
    }

    private func save() {
        do {
            defaults.set(try JSONEncoder().encode(tasks), forKey: storageKey)
        } catch {
            errorMessage = "Your changes could not be saved. Please try again."
        }
    }
}
