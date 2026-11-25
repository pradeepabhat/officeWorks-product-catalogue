import Foundation
import Testing
@testable import officeWorksProducts

struct EndpointTests {
    private let baseURL = URL(string: "http://localhost:3000/api/")!

    @Test(arguments: [
        (Endpoint.featuredProducts, "http://localhost:3000/api/products/featured"),
        (Endpoint.searchProducts(query: "c++ pen"), "http://localhost:3000/api/products/search?q=c%2B%2B%20pen"),
        (Endpoint.productDetail(id: "P1001"), "http://localhost:3000/api/products?id=P1001"),
        (Endpoint.fetchAllProducts, "http://localhost:3000/api/fetchAllProducts"),
        (Endpoint.categories, "http://localhost:3000/api/categories"),
    ])
    func buildsGetRequest(endpoint: Endpoint, expectedURL: String) throws {
        let request = try endpoint.makeRequest(baseURL: baseURL)

        #expect(request.url?.absoluteString == expectedURL)
        #expect(request.httpMethod == "GET")
        #expect(request.httpBody == nil)
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test func baseURLWithoutTrailingSlashIsHandled() throws {
        let request = try Endpoint.categories.makeRequest(baseURL: URL(string: "http://localhost:3000/api")!)
        #expect(request.url?.absoluteString == "http://localhost:3000/api/categories")
    }

    @Test func appliesTimeout() throws {
        let request = try Endpoint.categories.makeRequest(baseURL: baseURL, timeout: 5)
        #expect(request.timeoutInterval == 5)
    }

    @Test func idWithSpecialCharactersIsEncoded() throws {
        let request = try Endpoint.productDetail(id: "a&b=c").makeRequest(baseURL: baseURL)
        let items = URLComponents(url: try #require(request.url), resolvingAgainstBaseURL: false)?.queryItems
        #expect(items?.first?.name == "id")
        #expect(items?.first?.value == "a&b=c")
    }
}
