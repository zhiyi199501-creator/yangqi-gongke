import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                TodayView()
            }
            .tabItem {
                Label("今日", systemImage: "sun.max.fill")
            }

            NavigationStack {
                JournalView()
            }
            .tabItem {
                Label("本月", systemImage: "calendar")
            }
        }
        .preferredColorScheme(.light)
        .tint(InkTheme.seal)
        .toolbarBackground(InkTheme.card, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
