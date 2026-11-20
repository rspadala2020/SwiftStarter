import SwiftUI

@main
struct SwiftStarterApp: App {
    @State private var store = TaskStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
