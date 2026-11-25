import SwiftUI

struct HomeView: View {
    @State var viewModel: HomeViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Button {
                    Task { await viewModel.toggleFeatured() }
                } label: {
                    Text("Featured")
                        .padding(.horizontal, 8)
                        .foregroundStyle(viewModel.isFeaturedSelected ? Color.white : Color.accentColor)
                        .padding(.vertical, 4)
                        .background(viewModel.isFeaturedSelected ? Color.accentColor : Color.clear, in: Capsule())
                        .overlay(Capsule().stroke(Color.accentColor))
                }
                .buttonStyle(.plain)
                .padding(.horizontal)

                ProductListContent(state: viewModel.state)
            }
            .navigationTitle("Home")
            .task { await viewModel.loadIfNeeded() }
        }
    }
}

struct ProductListContent: View {
    let state: LoadState<[Product]>

    var body: some View {
        switch state {
        case .idle:
            Color.clear
        case .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            Text(message).foregroundStyle(.red).padding()
        case .loaded(let products):
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(products) { ProductCardView(product: $0) }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}
