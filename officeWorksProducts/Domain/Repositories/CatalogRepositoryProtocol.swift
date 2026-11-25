import Foundation

/// Catalogue data source abstraction. ViewModels depend only on this protocol.
nonisolated protocol CatalogRepositoryProtocol: Sendable {
    func fetchFeaturedProducts() async throws -> [Product]
    func searchProducts(query: String) async throws -> [Product]
    func fetchProductDetail(id: Product.ID) async throws -> Product
    func fetchAllProducts() async throws -> [Product]
    func fetchCategories() async throws -> [String]
}
