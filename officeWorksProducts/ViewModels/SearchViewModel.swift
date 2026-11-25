import Foundation
import Observation

@MainActor
@Observable
final class SearchViewModel {
    private(set) var state: LoadState<[Product]> = .idle
    var query = "" {
        didSet { if query != oldValue { state = .idle } }
    }
    private let repository: any CatalogRepositoryProtocol

    init(repository: any CatalogRepositoryProtocol) {
        self.repository = repository
    }

    /// Calls `/products/search?q=<term>`.
    func search() async {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else {
            state = .idle
            return
        }
        state = .loading
        do {
            state = .loaded(try await repository.searchProducts(query: term))
        } catch {
            if error.isCancellation { return }
            state = .failed(message: error.userFacingMessage)
        }
    }
}
