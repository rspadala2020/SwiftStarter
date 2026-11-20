import SwiftUI

struct ContentView: View {
    @Bindable var store: TaskStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NewTaskView(onAdd: store.add)
                    .padding()

                if store.tasks.isEmpty {
                    ContentUnavailableView(
                        "A fresh start",
                        systemImage: "checklist",
                        description: Text("Add your first task above to get started.")
                    )
                } else {
                    List {
                        ForEach(store.tasks) { task in
                            TaskRow(task: task) {
                                store.toggle(task.id)
                            }
                        }
                        .onDelete(perform: store.delete)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                if !store.tasks.isEmpty {
                    EditButton()
                }
            }
            .alert("Task storage", isPresented: Binding(
                get: { store.errorMessage != nil },
                set: { if !$0 { store.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { store.errorMessage = nil }
            } message: {
                Text(store.errorMessage ?? "")
            }
        }
    }
}

private struct NewTaskView: View {
    let onAdd: (String) -> Void
    @State private var title = ""

    var body: some View {
        HStack {
            TextField("What needs doing?", text: $title)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
                .onSubmit(addTask)
                .accessibilityLabel("New task")

            Button(action: addTask) {
                Label("Add task", systemImage: "plus")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderedProminent)
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func addTask() {
        onAdd(title)
        title = ""
    }
}

private struct TaskRow: View {
    let task: TaskItem
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isComplete ? Color.green : Color.secondary)
                    .font(.title2)
                Text(task.title)
                    .strikethrough(task.isComplete)
                    .foregroundStyle(task.isComplete ? .secondary : .primary)
                Spacer()
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(task.title)
        .accessibilityValue(task.isComplete ? "Completed" : "Incomplete")
        .accessibilityHint("Double-tap to change completion status")
    }
}
