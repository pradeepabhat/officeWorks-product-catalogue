import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private(set) var state: LoadState<[Product]> = .idle
    private(set) var isFeaturedSelected = true
    private let repository: any CatalogRepositoryProtocol

    init(repository: any CatalogRepositoryProtocol) {
        self.repository = repository
    }

    /// Loads only on first appearance, so returning from a details screen doesn't refetch.
    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await load()
    }

    /// `/products/featured` when selected, otherwise `/fetchAllProducts`.
    func load() async {
        state = .loading
        do {
            let products = isFeaturedSelected
                ? try await repository.fetchFeaturedProducts()
                : try await repository.fetchAllProducts()
            state = .loaded(products)
        } catch {
            if error.isCancellation { state = .idle; return }
            state = .failed(message: error.userFacingMessage)
        }
    }

    func toggleFeatured() async {
        isFeaturedSelected.toggle()
        await load()
    }
}
