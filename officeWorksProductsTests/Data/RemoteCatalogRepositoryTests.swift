import Foundation
import Testing
@testable import officeWorksProducts

struct RemoteCatalogRepositoryTests {
    private let productJSON = #"{"id":1,"title":"Pen","price":2.5,"category":"stationery"}"#

    @Test func fetchFeaturedCallsFeaturedEndpoint() async throws {
        let client = StubAPIClient(json: "[\(productJSON)]")
        let products = try await RemoteCatalogRepository(client: client).fetchFeaturedProducts()

        #expect(products.map(\.name) == ["Pen"])
        #expect(client.requestedURLs.map(\.path) == ["/api/products/featured"])
    }

    @Test func fetchAllCallsFetchAllProductsEndpoint() async throws {
        let client = StubAPIClient(json: "[\(productJSON)]")
        let products = try await RemoteCatalogRepository(client: client).fetchAllProducts()

        #expect(products.count == 1)
        #expect(client.requestedURLs.map(\.path) == ["/api/fetchAllProducts"])
    }

    @Test func fetchCategoriesCallsCategoriesEndpoint() async throws {
        let client = StubAPIClient(json: #"["a","b"]"#)
        let categories = try await RemoteCatalogRepository(client: client).fetchCategories()

        #expect(categories == ["a", "b"])
        #expect(client.requestedURLs.map(\.path) == ["/api/categories"])
    }

    @Test func searchTrimsQueryAndPassesItToEndpoint() async throws {
        let client = StubAPIClient(json: "[\(productJSON)]")
        let products = try await RemoteCatalogRepository(client: client).searchProducts(query: "  pen  ")

        #expect(products.count == 1)
        #expect(client.requestedURLs.first?.absoluteString == "https://example.com/api/products/search?q=pen")
    }

    @Test(arguments: ["", "   ", "\n"])
    func blankSearchReturnsEmptyWithoutNetworkCall(query: String) async throws {
        let client = StubAPIClient(json: "[]")
        let products = try await RemoteCatalogRepository(client: client).searchProducts(query: query)

        #expect(products.isEmpty)
        #expect(client.requestedURLs.isEmpty)
    }

    @Test func fetchDetailPassesIdAndDecodesObject() async throws {
        let client = StubAPIClient(json: productJSON)
        let product = try await RemoteCatalogRepository(client: client).fetchProductDetail(id: "1")

        #expect(product.id == "1")
        #expect(client.requestedURLs.first?.absoluteString == "https://example.com/api/products?id=1")
    }

    @Test func fetchDetailAcceptsWrappedObject() async throws {
        let client = StubAPIClient(json: #"{"data":\#(productJSON)}"#)
        let product = try await RemoteCatalogRepository(client: client).fetchProductDetail(id: "1")
        #expect(product.name == "Pen")
    }

    @Test func clientErrorsPropagate() async {
        let client = StubAPIClient { _ in throw NetworkError.httpStatus(500) }
        await #expect(throws: NetworkError.httpStatus(500)) {
            try await RemoteCatalogRepository(client: client).fetchAllProducts()
        }
    }
}
