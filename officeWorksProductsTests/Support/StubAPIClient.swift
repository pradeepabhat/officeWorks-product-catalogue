import Foundation
@testable import officeWorksProducts

/// Fake `APIClientProtocol`: records requested URLs and decodes canned JSON, like the real client.
final class StubAPIClient: APIClientProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var recorded: [URL] = []
    private let baseURL = URL(string: "https://example.com/api")!
    private let handler: @Sendable (URL) throws -> Data

    init(handler: @escaping @Sendable (URL) throws -> Data) {
        self.handler = handler
    }

    convenience init(json: String) {
        self.init { _ in Data(json.utf8) }
    }

    var requestedURLs: [URL] {
        lock.lock(); defer { lock.unlock() }
        return recorded
    }

    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint, as type: Response.Type) async throws -> Response {
        guard let url = try endpoint.makeRequest(baseURL: baseURL).url else { throw NetworkError.invalidURL }
        lock.lock(); recorded.append(url); lock.unlock()

        let data = try handler(url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Response.self, from: data)
    }
}
