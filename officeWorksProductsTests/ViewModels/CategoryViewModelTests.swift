import Foundation
import Testing
@testable import officeWorksProducts

@MainActor
struct CategoryViewModelTests {
    private let repository = StubCatalogRepository()

    @Test func loadPopulatesCategoriesWithAllFirstAndShowsEverything() async {
        let viewModel = CategoryViewModel(repository: repository)
        await viewModel.load()

        #expect(viewModel.categories == ["All"] + TestData.categories)
        #expect(viewModel.selectedCategory == "All")
        #expect(viewModel.state == .loaded(TestData.all))
        #expect(await repository.categoriesCalls == 1)
        #expect(await repository.allCalls == 1)
    }

    @Test func selectingCategoryFiltersWithoutCallingAPIAgain() async {
        let viewModel = CategoryViewModel(repository: repository)
        await viewModel.load()

        viewModel.selectCategory("jewelery")

        #expect(viewModel.state == .loaded([TestData.ring]))
        #expect(await repository.allCalls == 1)
        #expect(await repository.categoriesCalls == 1)
    }

    @Test func filteringIsCaseInsensitive() async {
        let viewModel = CategoryViewModel(repository: repository)
        await viewModel.load()

        viewModel.selectCategory("ELECTRONICS")
        #expect(viewModel.state == .loaded([TestData.laptop]))
    }

    @Test func selectingAllRestoresFullList() async {
        let viewModel = CategoryViewModel(repository: repository)
        await viewModel.load()
        viewModel.selectCategory("jewelery")
        viewModel.selectCategory(CategoryViewModel.allCategories)

        #expect(viewModel.state == .loaded(TestData.all))
    }

    @Test func unknownCategoryYieldsEmptyList() async {
        let viewModel = CategoryViewModel(repository: repository)
        await viewModel.load()
        viewModel.selectCategory("toys")

        #expect(viewModel.state == .loaded([]))
    }

    @Test func loadIfNeededOnlyFetchesOnce() async {
        let viewModel = CategoryViewModel(repository: repository)
        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()

        #expect(await repository.allCalls == 1)
        #expect(await repository.categoriesCalls == 1)
    }

    @Test func categoriesFailureShowsError() async {
        await repository.setCategories(.failure(.invalidResponse))
        let viewModel = CategoryViewModel(repository: repository)
        await viewModel.load()

        #expect(viewModel.state == .failed(message: NetworkError.invalidResponse.userFacingMessage))
        #expect(viewModel.categories == ["All"])
    }

    @Test func productsFailureShowsError() async {
        await repository.setAll(.failure(.httpStatus(500)))
        let viewModel = CategoryViewModel(repository: repository)
        await viewModel.load()

        #expect(viewModel.state == .failed(message: NetworkError.httpStatus(500).userFacingMessage))
    }

    @Test func cancellationResetsToIdle() async {
        await repository.setAll(.failure(.cancelled))
        let viewModel = CategoryViewModel(repository: repository)
        await viewModel.load()

        #expect(viewModel.state == .idle)
    }
}
