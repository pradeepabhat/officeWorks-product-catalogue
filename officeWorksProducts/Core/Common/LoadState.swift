import Foundation

/// Async loading state shared by ViewModels.
nonisolated enum LoadState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(message: String)
}

extension LoadState: Equatable where Value: Equatable {}
extension LoadState: Sendable where Value: Sendable {}

extension Error {
    /// Message suitable for showing to the user.
    nonisolated var userFacingMessage: String {
        (self as? LocalizedError)?.errorDescription ?? "Something went wrong. Please try again."
    }

    /// Cancellation is expected (e.g. a view disappearing) and should not surface as an error.
    nonisolated var isCancellation: Bool {
        self is CancellationError || (self as? NetworkError) == .cancelled
    }
}
