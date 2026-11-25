import Foundation
import Testing
@testable import officeWorksProducts

@MainActor
struct SearchViewModelTests {
    private let repository = StubCatalogRepository()

    @Test func startsIdle() {
        #expect(SearchViewModel(repository: repository).state == .idle)
    }

    @Test(arguments: ["", "   ", "\n"])
    func blankQueryDoesNotCallAPI(query: String) async {
        let viewModel = SearchViewModel(repository: repository)
        viewModel.query = query
        await viewModel.search()

        #expect(viewModel.state == .idle)
        #expect(await repository.searchQueries.isEmpty)
    }

    @Test func searchPassesTrimmedQueryAndShowsResults() async {
        await repository.setSearch(.success([TestData.laptop]))
        let viewModel = SearchViewModel(repository: repository)
        viewModel.query = "  laptop "
        await viewModel.search()

        #expect(await repository.searchQueries == ["laptop"])
        #expect(viewModel.state == .loaded([TestData.laptop]))
    }

    @Test func noMatchesIsLoadedEmpty() async {
        let viewModel = SearchViewModel(repository: repository)
        viewModel.query = "zzz"
        await viewModel.search()

        #expect(viewModel.state == .loaded([]))
    }

    @Test func editingQueryClearsResults() async {
        await repository.setSearch(.success([TestData.laptop]))
        let viewModel = SearchViewModel(repository: repository)
        viewModel.query = "laptop"
        await viewModel.search()
        #expect(viewModel.state == .loaded([TestData.laptop]))

        viewModel.query = "laptops"
        #expect(viewModel.state == .idle)
    }

    @Test func settingSameQueryKeepsResults() async {
        await repository.setSearch(.success([TestData.laptop]))
        let viewModel = SearchViewModel(repository: repository)
        viewModel.query = "laptop"
        await viewModel.search()

        viewModel.query = "laptop"
        #expect(viewModel.state == .loaded([TestData.laptop]))
    }

    @Test func failureShowsMessage() async {
        await repository.setSearch(.failure(.transport(.notConnectedToInternet)))
        let viewModel = SearchViewModel(repository: repository)
        viewModel.query = "pen"
        await viewModel.search()

        #expect(viewModel.state == .failed(message: NetworkError.transport(.notConnectedToInternet).userFacingMessage))
    }
}
