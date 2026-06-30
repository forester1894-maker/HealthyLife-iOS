import SwiftUI

@main
struct HealthyLifeApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .tint(AppTheme.primary)
        }
    }
}
