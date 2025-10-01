import SwiftUI

@main
struct PhysicsLabApp: App {
    @StateObject private var experimentStore = ExperimentStore()

    var body: some Scene {
        WindowGroup {
            ExperimentListView()
                .environmentObject(experimentStore)
        }
    }
}
