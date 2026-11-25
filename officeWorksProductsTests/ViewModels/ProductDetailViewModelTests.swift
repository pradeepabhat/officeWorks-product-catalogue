import Foundation
import Testing
@testable import officeWorksProducts

@MainActor
struct ProductDetailViewModelTests {
    private let repository = StubCatalogRepository()

    @Test func startsWithSuppliedProduct() {
        let viewModel = ProductDetailViewModel(product: TestData.ring, repository: repository)

        #expect(viewModel.product == TestData.ring)
        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func loadFetchesDetailByIdAndReplacesProduct() async {
        let detailed = Product(id: "2", name: "Gold Ring XL", description: "Full details", price: 300, category: "jewelery")
        await repository.setDetail(.success(detailed))
        let viewModel = ProductDetailViewModel(product: TestData.ring, repository: repository)

        await viewModel.load()

        #expect(await repository.detailIDs == ["2"])
        #expect(viewModel.product == detailed)
        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func failureKeepsOriginalProductAndSetsMessage() async {
        await repository.setDetail(.failure(.httpStatus(404)))
        let viewModel = ProductDetailViewModel(product: TestData.ring, repository: repository)

        await viewModel.load()

        #expect(viewModel.product == TestData.ring)
        #expect(viewModel.errorMessage == NetworkError.httpStatus(404).userFacingMessage)
        #expect(!viewModel.isLoading)
    }

    @Test func successfulReloadClearsPreviousError() async {
        await repository.setDetail(.failure(.invalidResponse))
        let viewModel = ProductDetailViewModel(product: TestData.ring, repository: repository)
        await viewModel.load()
        #expect(viewModel.errorMessage != nil)

        await repository.setDetail(.success(TestData.ring))
        await viewModel.load()
        #expect(viewModel.errorMessage == nil)
    }

    @Test func cancellationDoesNotSurfaceAnError() async {
        await repository.setDetail(.failure(.cancelled))
        let viewModel = ProductDetailViewModel(product: TestData.ring, repository: repository)

        await viewModel.load()

        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.isLoading)
    }
}
