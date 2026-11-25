import SwiftUI

struct CategoryView: View {
    @State var viewModel: CategoryViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Category", selection: Binding(
                    get: { viewModel.selectedCategory },
                    set: { viewModel.selectCategory($0) }
                )) {
                    ForEach(viewModel.categories, id: \.self) { Text($0.capitalized).tag($0) }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)

                ProductListContent(state: viewModel.state)
            }
            .navigationTitle("Category")
            .task { await viewModel.loadIfNeeded() }
        }
    }
}
