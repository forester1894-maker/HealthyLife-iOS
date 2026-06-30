import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            switch appState.currentRoute {
            case .activation:
                ActivationView()
            case .consent:
                ConsentView()
            case .survey:
                SurveyView()
            case .main:
                MainTabView()
            }
        }
        .background(AppTheme.background)
        .task { await appState.bootstrap() }
    }
}
