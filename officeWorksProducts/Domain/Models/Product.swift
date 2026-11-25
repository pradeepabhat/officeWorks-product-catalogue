import Foundation

nonisolated struct Product: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let description: String
    let price: Decimal
    let currencyCode: String
    let category: String
    let imageURL: URL?

    init(
        id: String,
        name: String,
        description: String,
        price: Decimal,
        currencyCode: String = "USD",
        category: String,
        imageURL: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.currencyCode = currencyCode
        self.category = category
        self.imageURL = imageURL
    }

    var formattedPrice: String {
        price.formatted(.currency(code: currencyCode))
    }
}
