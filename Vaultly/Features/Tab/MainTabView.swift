import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            Tab("Transactions", systemImage: "list.bullet.rectangle.fill") {
               TransactionsView()
            }
            Tab("Budgets", systemImage: "chart.pie.fill") {
                BudgetView()
            }
            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsView()
            }
        }
    }
}

private struct PlaceholderScreen: View {
    let title: String
    let message: String

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                ContentUnavailableView {
                    Label("\(title) coming soon", systemImage: "hammer.fill")
                } description: {
                    Text(message)
                }
            }
            .navigationTitle(title)
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(PersistenceController.preview())
}
