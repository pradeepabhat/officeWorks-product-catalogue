import Foundation
import Testing
@testable import officeWorksProducts

@Suite(.serialized)
struct APIClientTests {
    private let baseURL = URL(string: "https://example.com/api")!

    private func makeClient() -> APIClient {
        APIClient(baseURL: baseURL, session: MockURLProtocol.makeSession())
    }

    private func respond(status: Int = 200, body: String) {
        MockURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
            return (response, Data(body.utf8))
        }
    }

    @Test func decodesSuccessfulResponseAndBuildsRequest() async throws {
        nonisolated(unsafe) var captured: URLRequest?
        MockURLProtocol.handler = { request in
            captured = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(#"[{"id":1,"title":"Pen","price":1.5,"category":"stationery","image":"https://x.com/a.png"}]"#.utf8))
        }

        let result = try await makeClient().send(.featuredProducts, as: ListResponse<ProductDTO>.self)

        #expect(result.items.count == 1)
        #expect(result.items[0].name == "Pen")
        #expect(captured?.url?.absoluteString == "https://example.com/api/products/featured")
        #expect(captured?.httpMethod == "GET")
        #expect(captured?.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test(arguments: [400, 404, 500])
    func nonSuccessStatusThrowsHTTPStatus(status: Int) async {
        respond(status: status, body: "{}")
        await #expect(throws: NetworkError.httpStatus(status)) {
            try await makeClient().send(.categories, as: ListResponse<CategoryDTO>.self)
        }
    }

    @Test func malformedBodyThrowsDecodingFailed() async {
        respond(body: #"{"unexpected": true}"#)
        await #expect {
            try await makeClient().send(.fetchAllProducts, as: ListResponse<ProductDTO>.self)
        } throws: { error in
            if case NetworkError.decodingFailed = error { return true }
            return false
        }
    }

    @Test func connectivityFailureIsMappedToTransport() async {
        MockURLProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }
        await #expect(throws: NetworkError.transport(.notConnectedToInternet)) {
            try await makeClient().send(.categories, as: ListResponse<CategoryDTO>.self)
        }
    }

    @Test func urlSessionCancellationIsMappedToCancelled() async {
        MockURLProtocol.handler = { _ in throw URLError(.cancelled) }
        await #expect(throws: NetworkError.cancelled) {
            try await makeClient().send(.categories, as: ListResponse<CategoryDTO>.self)
        }
    }

    @Test func configuredBaseURLReadsInfoDictionary() {
        let url = APIClient.configuredBaseURL(infoDictionary: ["API_BASE_URL": "https://api.example.com/v1"])
        #expect(url.absoluteString == "https://api.example.com/v1")
    }

    @Test func configuredBaseURLFallsBackToDefault() {
        let invalid: [[String: Any]] = [
            [:],
            ["API_BASE_URL": ""],
            ["API_BASE_URL": "ftp://example.com"],
            ["API_BASE_URL": "not a url"],
            ["API_BASE_URL": 42],
        ]
        for info in invalid {
            #expect(APIClient.configuredBaseURL(infoDictionary: info) == APIClient.defaultBaseURL)
        }
    }
}
