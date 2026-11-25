import Foundation

/// `CatalogRepositoryProtocol` backed by the REST API.
nonisolated struct RemoteCatalogRepository: CatalogRepositoryProtocol {
    private let client: any APIClientProtocol

    init(client: any APIClientProtocol = APIClient()) {
        self.client = client
    }

    func fetchFeaturedProducts() async throws -> [Product] {
        try await client.send(.featuredProducts, as: ListResponse<ProductDTO>.self).items.map { $0.toDomain() }
    }

    func searchProducts(query: String) async throws -> [Product] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return try await client.send(.searchProducts(query: trimmed), as: ListResponse<ProductDTO>.self)
            .items
            .map { $0.toDomain() }
    }

    func fetchProductDetail(id: Product.ID) async throws -> Product {
        try await client.send(.productDetail(id: id), as: ObjectResponse<ProductDTO>.self).value.toDomain()
    }

    func fetchAllProducts() async throws -> [Product] {
        try await client.send(.fetchAllProducts, as: ListResponse<ProductDTO>.self).items.map { $0.toDomain() }
    }

    func fetchCategories() async throws -> [String] {
        try await client.send(.categories, as: ListResponse<CategoryDTO>.self).items.map(\.name)
    }
}
