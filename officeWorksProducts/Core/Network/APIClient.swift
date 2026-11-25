import Foundation

nonisolated protocol APIClientProtocol: Sendable {
    /// Sends the request, validates a 2xx status and decodes the body into `Response`.
    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint, as type: Response.Type) async throws -> Response
}

/// Generic HTTP client built solely on `URLSession` and `async/await`.
nonisolated struct APIClient: APIClientProtocol {
    let baseURL: URL
    private let session: URLSession
    private let timeout: TimeInterval
    private let logger: NetworkLogger

    init(
        baseURL: URL = APIClient.configuredBaseURL(),
        session: URLSession = .shared,
        timeout: TimeInterval = 30,
        logger: NetworkLogger = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
        self.timeout = timeout
        self.logger = logger
    }

    // MARK: - APIClientProtocol

    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint, as type: Response.Type) async throws -> Response {
        let request = try endpoint.makeRequest(baseURL: baseURL, timeout: timeout)
        let data = try await perform(request)
        return try await Self.decode(Response.self, from: data, logger: logger)
    }

    // MARK: - Request pipeline

    /// Sends the request and returns the body of a 2xx response.
    private func perform(_ request: URLRequest) async throws -> Data {
        logger.logRequest(request)

        let (data, response) = try await transport(request)
        let httpResponse = try httpResponse(from: response, for: request)
        logger.logResponse(httpResponse, data: data, for: request)

        try Self.validate(statusCode: httpResponse.statusCode)
        return data
    }

    /// Performs the network call, mapping low-level failures to `NetworkError`.
    private func transport(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch is CancellationError {
            throw NetworkError.cancelled
        } catch let error as URLError {
            logger.logTransportFailure(error, for: request)
            throw error.code == .cancelled ? NetworkError.cancelled : NetworkError.transport(error.code)
        }
    }

    private func httpResponse(from response: URLResponse, for request: URLRequest) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.logInvalidResponse(for: request)
            throw NetworkError.invalidResponse
        }
        return httpResponse
    }

    private static func validate(statusCode: Int) throws {
        guard (200...299).contains(statusCode) else { throw NetworkError.httpStatus(statusCode) }
    }

    // MARK: - Decoding

    /// Decodes off the caller's actor so large payloads never block the main thread.
    @concurrent
    private static func decode<T: Decodable & Sendable>(_ type: T.Type, from data: Data, logger: NetworkLogger) async throws -> T {
        do {
            return try makeDecoder().decode(T.self, from: data)
        } catch {
            logger.logDecodingFailure(error, as: T.self)
            throw NetworkError.decodingFailed(String(describing: error))
        }
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

// MARK: - Configuration

extension APIClient {
    static let baseURLInfoPlistKey = "API_BASE_URL"
    static let defaultBaseURL = URL(string: "http://localhost:3000/")!

    /// Reads `API_BASE_URL` from the Info.plist, falling back to `defaultBaseURL`.
    static func configuredBaseURL(infoDictionary: [String: Any]? = Bundle.main.infoDictionary) -> URL {
        guard
            let raw = (infoDictionary?[baseURLInfoPlistKey] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
            !raw.isEmpty,
            let url = URL(string: raw),
            let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https",
            url.host() != nil
        else {
            return defaultBaseURL
        }
        return url
    }
}
