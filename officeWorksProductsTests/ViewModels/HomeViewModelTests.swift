import Foundation
import Testing
@testable import officeWorksProducts

@MainActor
struct HomeViewModelTests {
    private let repository = StubCatalogRepository()

    @Test func startsIdleWithFeaturedSelected() {
        let viewModel = HomeViewModel(repository: repository)
        #expect(viewModel.state == .idle)
        #expect(viewModel.isFeaturedSelected)
    }

    @Test func loadFetchesFeaturedByDefault() async {
        let viewModel = HomeViewModel(repository: repository)
        await viewModel.load()

        #expect(viewModel.state == .loaded(TestData.featured))
        #expect(await repository.featuredCalls == 1)
        #expect(await repository.allCalls == 0)
    }

    @Test func loadIfNeededOnlyFetchesOnce() async {
        let viewModel = HomeViewModel(repository: repository)
        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()

        #expect(await repository.featuredCalls == 1)
    }

    @Test func unselectingFeaturedFetchesAllProducts() async {
        let viewModel = HomeViewModel(repository: repository)
        await viewModel.loadIfNeeded()
        await viewModel.toggleFeatured()

        #expect(!viewModel.isFeaturedSelected)
        #expect(viewModel.state == .loaded(TestData.all))
        #expect(await repository.allCalls == 1)
    }

    @Test func reselectingFeaturedFetchesFeaturedAgain() async {
        let viewModel = HomeViewModel(repository: repository)
        await viewModel.toggleFeatured()
        await viewModel.toggleFeatured()

        #expect(viewModel.isFeaturedSelected)
        #expect(viewModel.state == .loaded(TestData.featured))
        #expect(await repository.featuredCalls == 1)
        #expect(await repository.allCalls == 1)
    }

    @Test func failureProducesUserFacingMessage() async {
        await repository.setFeatured(.failure(.httpStatus(500)))
        let viewModel = HomeViewModel(repository: repository)
        await viewModel.load()

        #expect(viewModel.state == .failed(message: NetworkError.httpStatus(500).userFacingMessage))
    }

    @Test func canRetryAfterFailure() async {
        await repository.setFeatured(.failure(.invalidResponse))
        let viewModel = HomeViewModel(repository: repository)
        await viewModel.load()

        await repository.setFeatured(.success(TestData.featured))
        await viewModel.load()

        #expect(viewModel.state == .loaded(TestData.featured))
    }

    @Test func cancelledRequestResetsToIdleSoItCanRetry() async {
        await repository.setFeatured(.failure(.cancelled))
        let viewModel = HomeViewModel(repository: repository)
        await viewModel.load()

        #expect(viewModel.state == .idle)
    }
}
