import Foundation
import Testing
@testable import officeWorksProducts

struct NetworkErrorTests {
    @Test func transportConnectivityErrorsMentionConnection() {
        for code in [URLError.Code.notConnectedToInternet, .timedOut, .cannotFindHost] {
            #expect(NetworkError.transport(code).errorDescription?.contains("connection") == true)
        }
    }

    @Test func otherTransportErrorsUseGenericMessage() {
        #expect(NetworkError.transport(.badURL).errorDescription == "A network error occurred. Please try again.")
    }

    @Test func httpStatusMessages() {
        #expect(NetworkError.httpStatus(404).errorDescription == "We couldn't find what you were looking for.")
        #expect(NetworkError.httpStatus(400).errorDescription?.contains("400") == true)
        #expect(NetworkError.httpStatus(500).errorDescription?.contains("500") == true)
    }

    @Test func otherCasesHaveDescriptions() {
        #expect(NetworkError.invalidURL.errorDescription != nil)
        #expect(NetworkError.invalidResponse.errorDescription != nil)
        #expect(NetworkError.decodingFailed("x").errorDescription != nil)
        #expect(NetworkError.cancelled.errorDescription != nil)
    }
}

struct LoadStateTests {
    @Test func userFacingMessageUsesLocalizedError() {
        #expect(NetworkError.invalidURL.userFacingMessage == "The request URL is invalid.")
    }

    @Test func userFacingMessageFallsBackForUnknownErrors() {
        struct Unknown: Error {}
        #expect(Unknown().userFacingMessage == "Something went wrong. Please try again.")
    }

    @Test func cancellationDetection() {
        #expect(CancellationError().isCancellation)
        #expect(NetworkError.cancelled.isCancellation)
        #expect(!NetworkError.invalidURL.isCancellation)
    }

    @Test func equatableWhenValueIsEquatable() {
        #expect(LoadState<Int>.loaded(1) == .loaded(1))
        #expect(LoadState<Int>.loaded(1) != .loaded(2))
        #expect(LoadState<Int>.idle != .loading)
    }
}
