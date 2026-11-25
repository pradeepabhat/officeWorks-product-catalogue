import Foundation

/// Typed errors surfaced by the network layer.
nonisolated enum NetworkError: Error, Equatable, Sendable {
    case invalidURL
    case transport(URLError.Code)
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed(String)
    case cancelled
}

extension NetworkError: LocalizedError {
    nonisolated var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .transport(let code):
            switch code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost, .cannotFindHost, .timedOut:
                return "We couldn't reach the server. Check your connection and try again."
            default:
                return "A network error occurred. Please try again."
            }
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .httpStatus(let code):
            switch code {
            case 404: return "We couldn't find what you were looking for."
            case 400..<500: return "The request couldn't be completed (error \(code))."
            default: return "The server is having trouble right now (error \(code)). Please try again later."
            }
        case .decodingFailed:
            return "We received data we couldn't read."
        case .cancelled:
            return "The request was cancelled."
        }
    }
}
