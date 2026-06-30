import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Сегодня", systemImage: "sun.max") }
            PlanView()
                .tabItem { Label("План", systemImage: "calendar") }
            DiaryView()
                .tabItem { Label("Дневник", systemImage: "book") }
            MoreView()
                .tabItem { Label("Ещё", systemImage: "ellipsis.circle") }
        }
        .tint(AppTheme.primary)
    }
}
