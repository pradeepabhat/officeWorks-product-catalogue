import SwiftUI

struct MainTabView: View {
    let repository: any CatalogRepositoryProtocol

    var body: some View {
        TabView {
            HomeView(viewModel: HomeViewModel(repository: repository))
                .tabItem { Label("Home", systemImage: "house") }
            CategoryView(viewModel: CategoryViewModel(repository: repository))
                .tabItem { Label("Category", systemImage: "square.grid.2x2") }
            SearchView(viewModel: SearchViewModel(repository: repository))
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
        }
    }
}
