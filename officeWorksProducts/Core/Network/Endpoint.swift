import Foundation

nonisolated enum HTTPMethod: String, Sendable {
    case get = "GET"
}

/// Type-safe description of every API route. Paths are relative to the API base URL
/// (e.g. `http://localhost:3000/api`).
nonisolated enum Endpoint: Sendable {
    /// `GET /products/featured`
    case featuredProducts
    /// `GET /products/search?q=<term>`
    case searchProducts(query: String)
    /// `GET /products?id=<id>`
    case productDetail(id: String)
    /// `GET /fetchAllProducts`
    case fetchAllProducts
    /// `GET /categories`
    case categories

    var method: HTTPMethod { .get }

    /// Raw (unencoded) path segments; each is percent-encoded individually.
    var pathSegments: [String] {
        switch self {
        case .featuredProducts: ["products", "featured"]
        case .searchProducts: ["products", "search"]
        case .productDetail: ["products"]
        case .fetchAllProducts: ["fetchAllProducts"]
        case .categories: ["categories"]
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .featuredProducts, .fetchAllProducts, .categories: []
        case .searchProducts(let query): [URLQueryItem(name: "q", value: query)]
        case .productDetail(let id): [URLQueryItem(name: "id", value: id)]
        }
    }

    func makeRequest(baseURL: URL, timeout: TimeInterval = 30) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        var basePath = components.percentEncodedPath
        while basePath.hasSuffix("/") { basePath.removeLast() }
        let segments = try pathSegments.map { segment in
            guard let encoded = segment.addingPercentEncoding(withAllowedCharacters: Self.pathSegmentAllowed) else {
                throw NetworkError.invalidURL
            }
            return encoded
        }
        components.percentEncodedPath = ([basePath] + segments).joined(separator: "/")

        if !queryItems.isEmpty {
            components.queryItems = queryItems
            // URLComponents leaves "+" as-is, which servers decode as a space.
            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        }

        guard let url = components.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private static let pathSegmentAllowed: CharacterSet = {
        var set = CharacterSet.urlPathAllowed
        set.remove(charactersIn: "/;")
        return set
    }()
}
