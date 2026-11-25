import SwiftUI

struct SearchView: View {
    @State var viewModel: SearchViewModel

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Search")
                .searchable(
                    text: $viewModel.query,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search products"
                )
                .onSubmit(of: .search) { Task { await viewModel.search() } }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            placeholder(icon: "magnifyingglass", title: "Find products", message: "Type a term and tap Search on the keyboard.")
        case .loading:
            ProgressView("Searching…")
        case .failed(let message):
            placeholder(icon: "exclamationmark.triangle", title: "Something went wrong", message: message)
        case .loaded(let products) where products.isEmpty:
            placeholder(icon: "tray", title: "No results", message: "Try a different search term.")
        case .loaded(let products):
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(products) { ProductCardView(product: $0) }
                }
                .padding()
            }
        }
    }

    private func placeholder(icon: String, title: String, message: String) -> some View {
        ContentUnavailableView(title, systemImage: icon, description: Text(message))
    }
}
