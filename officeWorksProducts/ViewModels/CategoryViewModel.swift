import Foundation
import Observation

@MainActor
@Observable
final class CategoryViewModel {
    static let allCategories = "All"

    private(set) var categories: [String] = [allCategories]
    private(set) var state: LoadState<[Product]> = .idle
    var selectedCategory = allCategories

    private var allProducts: [Product] = []
    private let repository: any CatalogRepositoryProtocol

    init(repository: any CatalogRepositoryProtocol) {
        self.repository = repository
    }

    /// Loads only on first appearance, so returning from a details screen doesn't refetch.
    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await load()
    }

    /// Calls `/categories` then `/fetchAllProducts`.
    func load() async {
        state = .loading
        do {
            let names = try await repository.fetchCategories()
            categories = [Self.allCategories] + names
            allProducts = try await repository.fetchAllProducts()
            applyFilter()
        } catch {
            if error.isCancellation { state = .idle; return }
            state = .failed(message: error.userFacingMessage)
        }
    }

    /// Filters the already-fetched products; no network call.
    func selectCategory(_ category: String) {
        selectedCategory = category
        applyFilter()
    }

    private func applyFilter() {
        if selectedCategory == Self.allCategories {
            state = .loaded(allProducts)
        } else {
            state = .loaded(allProducts.filter { $0.category.caseInsensitiveCompare(selectedCategory) == .orderedSame })
        }
    }
}
