import Foundation
import Testing
@testable import officeWorksProducts

struct CatalogDTOTests {
    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: Data(json.utf8))
    }

    @Test func decodesDocumentedProductShape() throws {
        let json = #"{"id":7,"title":"Backpack","price":109.95,"description":"Nice","category":"men's clothing","image":"http://example.com/a.jpg"}"#
        let product = try decode(ProductDTO.self, json).toDomain()

        #expect(product.id == "7")
        #expect(product.name == "Backpack")
        #expect(product.price == Decimal(string: "109.95"))
        #expect(product.description == "Nice")
        #expect(product.category == "men's clothing")
        #expect(product.imageURL == URL(string: "http://example.com/a.jpg"))
        #expect(product.currencyCode == "USD")
    }

    @Test func acceptsStringIdAndPriceAndAlternativeKeys() throws {
        let json = #"{"_id":"abc","name":"Pen","unit_price":"$3.50","currency":"nzd","image_url":"https://x.com/p.png"}"#
        let product = try decode(ProductDTO.self, json).toDomain()

        #expect(product.id == "abc")
        #expect(product.name == "Pen")
        #expect(product.price == Decimal(string: "3.50"))
        #expect(product.currencyCode == "NZD")
        #expect(product.imageURL?.absoluteString == "https://x.com/p.png")
    }

    @Test func missingOptionalFieldsUseDefaults() throws {
        let product = try decode(ProductDTO.self, #"{"id":1,"title":"A","price":1}"#).toDomain()

        #expect(product.description == "")
        #expect(product.category == "")
        #expect(product.imageURL == nil)
    }

    @Test func categoryObjectIsFlattenedToName() throws {
        let product = try decode(ProductDTO.self, #"{"id":1,"title":"A","price":1,"category":{"name":"Toys"}}"#).toDomain()
        #expect(product.category == "Toys")
    }

    @Test func missingRequiredFieldsFail() {
        #expect(throws: DecodingError.self) { try decode(ProductDTO.self, #"{"id":1,"price":1}"#) }
        #expect(throws: DecodingError.self) { try decode(ProductDTO.self, #"{"id":1,"title":"A"}"#) }
        #expect(throws: DecodingError.self) { try decode(ProductDTO.self, #"{"title":"A","price":1}"#) }
    }

    @Test func invalidPriceFails() {
        #expect(throws: DecodingError.self) { try decode(ProductDTO.self, #"{"id":1,"title":"A","price":"free"}"#) }
    }

    @Test func listResponseAcceptsBareArrayAndEnvelopes() throws {
        let item = #"{"id":1,"title":"A","price":1}"#
        #expect(try decode(ListResponse<ProductDTO>.self, "[\(item)]").items.count == 1)
        for key in ["data", "items", "results", "products"] {
            #expect(try decode(ListResponse<ProductDTO>.self, #"{"\#(key)":[\#(item)]}"#).items.count == 1)
        }
    }

    @Test func listResponseDropsUndecodableElements() throws {
        let json = #"[{"id":1,"title":"A","price":1},{"bogus":true},{"id":2,"title":"B","price":2}]"#
        let items = try decode(ListResponse<ProductDTO>.self, json).items
        #expect(items.map(\.id) == ["1", "2"])
    }

    @Test func listResponseFailsForUnknownEnvelope() {
        #expect(throws: DecodingError.self) { try decode(ListResponse<ProductDTO>.self, #"{"foo":[]}"#) }
    }

    @Test func categoriesDecodeFromBareStringsAndObjects() throws {
        let strings = try decode(ListResponse<CategoryDTO>.self, #"["men's clothing","jewelery","electronics","women's clothing"]"#)
        #expect(strings.items.map(\.name) == TestData.categories)

        let objects = try decode(ListResponse<CategoryDTO>.self, #"[{"name":"Toys"},{"title":"Books"}]"#)
        #expect(objects.items.map(\.name) == ["Toys", "Books"])
    }

    @Test func objectResponseAcceptsBareAndWrapped() throws {
        let bare = try decode(ObjectResponse<ProductDTO>.self, #"{"id":1,"title":"A","price":1}"#)
        #expect(bare.value.id == "1")

        let wrapped = try decode(ObjectResponse<ProductDTO>.self, #"{"data":{"id":2,"title":"B","price":2}}"#)
        #expect(wrapped.value.id == "2")
    }

    @Test func objectResponseFailsWhenNothingMatches() {
        #expect(throws: DecodingError.self) { try decode(ObjectResponse<ProductDTO>.self, #"{"foo":1}"#) }
    }
}
