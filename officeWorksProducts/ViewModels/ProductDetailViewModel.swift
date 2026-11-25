import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class ProductDetailViewModel {
    private(set) var product: Product
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private let repository: any CatalogRepositoryProtocol

    init(product: Product, repository: any CatalogRepositoryProtocol = RemoteCatalogRepository()) {
        self.product = product
        self.repository = repository
    }

    /// Calls `/products?id=<id>`.
    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            product = try await repository.fetchProductDetail(id: product.id)
        } catch {
            if !error.isCancellation { errorMessage = error.userFacingMessage }
        }
        isLoading = false
    }
}
