import Foundation
@testable import officeWorksProducts

/// Configurable in-memory repository that records calls, for ViewModel tests.
actor StubCatalogRepository: CatalogRepositoryProtocol {
    var featuredResult: Result<[Product], NetworkError> = .success(TestData.featured)
    var allResult: Result<[Product], NetworkError> = .success(TestData.all)
    var categoriesResult: Result<[String], NetworkError> = .success(TestData.categories)
    var searchResult: Result<[Product], NetworkError> = .success([])
    var detailResult: Result<Product, NetworkError> = .success(TestData.laptop)

    private(set) var featuredCalls = 0
    private(set) var allCalls = 0
    private(set) var categoriesCalls = 0
    private(set) var searchQueries: [String] = []
    private(set) var detailIDs: [String] = []

    func setFeatured(_ result: Result<[Product], NetworkError>) { featuredResult = result }
    func setAll(_ result: Result<[Product], NetworkError>) { allResult = result }
    func setCategories(_ result: Result<[String], NetworkError>) { categoriesResult = result }
    func setSearch(_ result: Result<[Product], NetworkError>) { searchResult = result }
    func setDetail(_ result: Result<Product, NetworkError>) { detailResult = result }

    func fetchFeaturedProducts() async throws -> [Product] {
        featuredCalls += 1
        return try featuredResult.get()
    }

    func searchProducts(query: String) async throws -> [Product] {
        searchQueries.append(query)
        return try searchResult.get()
    }

    func fetchProductDetail(id: Product.ID) async throws -> Product {
        detailIDs.append(id)
        return try detailResult.get()
    }

    func fetchAllProducts() async throws -> [Product] {
        allCalls += 1
        return try allResult.get()
    }

    func fetchCategories() async throws -> [String] {
        categoriesCalls += 1
        return try categoriesResult.get()
    }
}
