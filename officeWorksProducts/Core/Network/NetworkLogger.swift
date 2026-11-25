import Foundation
import os

/// Logs network traffic to the unified logging system (category "Network").
nonisolated struct NetworkLogger: Sendable {
    static let shared = NetworkLogger()

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "officeWorksProducts",
        category: "Network"
    )

    func logRequest(_ request: URLRequest) {
        logger.debug("➡️ \(request.httpMethod ?? "GET", privacy: .public) \(request.urlString, privacy: .public)")
    }

    func logResponse(_ response: HTTPURLResponse, data: Data, for request: URLRequest) {
        let body = String(data: data, encoding: .utf8) ?? "<\(data.count) bytes, non-UTF8>"
        logger.debug("⬅️ \(response.statusCode) \(request.urlString, privacy: .public)\n\(body, privacy: .public)")
    }

    func logTransportFailure(_ error: URLError, for request: URLRequest) {
        logger.error("❌ \(request.urlString, privacy: .public) transport error: \(error.localizedDescription, privacy: .public)")
    }

    func logInvalidResponse(for request: URLRequest) {
        logger.error("❌ \(request.urlString, privacy: .public) invalid response")
    }

    func logDecodingFailure(_ error: Error, as type: Any.Type) {
        logger.error("❌ Decoding \(String(describing: type), privacy: .public) failed: \(String(describing: error), privacy: .public)")
    }
}

private nonisolated extension URLRequest {
    var urlString: String { url?.absoluteString ?? "<nil>" }
}
