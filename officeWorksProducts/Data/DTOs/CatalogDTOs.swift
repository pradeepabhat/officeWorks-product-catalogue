import Foundation

// The API contract isn't pinned down yet, so these decoders accept common variations
// (numeric/string ids and prices, alternative key names, bare arrays or `{ "data": ... }` envelopes).
// `APIClient` uses `.convertFromSnakeCase`, so keys below are camelCase.

nonisolated struct ProductDTO: Decodable, Sendable {
    let id: String
    let name: String
    let description: String?
    let price: Decimal
    let currency: String?
    let category: String?
    let imageURL: String?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        id = try c.require(FlexibleString.self, ["id", "_id", "productId", "sku"]).value
        name = try c.require(String.self, ["name", "title"])
        description = c.first(String.self, ["description", "details", "summary"])
        price = try c.require(FlexibleDecimal.self, ["price", "unitPrice", "amount"]).value
        currency = c.first(String.self, ["currency", "currencyCode"])
        category = c.first(String.self, ["category", "categoryName"]) ?? c.first(CategoryDTO.self, ["category"])?.name
        imageURL = c.first(String.self, ["imageUrl", "image", "thumbnail", "thumbnailUrl"])
    }

    func toDomain() -> Product {
        Product(
            id: id,
            name: name,
            description: description ?? "",
            price: price,
            currencyCode: currency?.uppercased() ?? "USD",
            category: category ?? "",
            imageURL: imageURL.flatMap(URL.init(string:))
        )
    }
}

/// A product's category as a bare string (`"Stationery"`) or an object (`{ "name": "Stationery" }`).
nonisolated struct CategoryDTO: Decodable, Sendable {
    let name: String

    init(from decoder: Decoder) throws {
        if let name = try? decoder.singleValueContainer().decode(String.self) {
            self.name = name
            return
        }
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        name = try c.require(String.self, ["name", "title", "slug"])
    }
}

// MARK: - Response envelopes

/// A list that is either a bare JSON array or wrapped in a common envelope key.
nonisolated struct ListResponse<Element: Decodable & Sendable>: Decodable, Sendable {
    let items: [Element]

    init(from decoder: Decoder) throws {
        if let array = try? LossyArray<Element>(from: decoder) {
            items = array.elements
            return
        }
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        items = try c.require(LossyArray<Element>.self, ["data", "items", "results", "products"]).elements
    }
}

/// A single object that is either bare or wrapped in a common envelope key.
nonisolated struct ObjectResponse<Value: Decodable & Sendable>: Decodable, Sendable {
    let value: Value

    init(from decoder: Decoder) throws {
        do {
            value = try Value(from: decoder)
        } catch {
            let c = try decoder.container(keyedBy: AnyCodingKey.self)
            guard let wrapped = c.first(Value.self, ["data", "product", "result"]) else { throw error }
            value = wrapped
        }
    }
}

// MARK: - Decoding helpers

nonisolated struct AnyCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init(_ string: String) {
        stringValue = string
        intValue = nil
    }

    init?(stringValue: String) { self.init(stringValue) }

    init?(intValue: Int) {
        stringValue = String(intValue)
        self.intValue = intValue
    }
}

nonisolated extension KeyedDecodingContainer where Key == AnyCodingKey {
    /// The first key whose value is non-null and decodes as `T`.
    func first<T: Decodable>(_ type: T.Type, _ keys: [String]) -> T? {
        for name in keys {
            let key = AnyCodingKey(name)
            guard contains(key), (try? decodeNil(forKey: key)) == false else { continue }
            if let value = try? decode(T.self, forKey: key) { return value }
        }
        return nil
    }

    func require<T: Decodable>(_ type: T.Type, _ keys: [String]) throws -> T {
        guard let value = first(type, keys) else {
            throw DecodingError.keyNotFound(
                AnyCodingKey(keys.first ?? ""),
                .init(codingPath: codingPath, debugDescription: "No valid \(T.self) for any of \(keys).")
            )
        }
        return value
    }
}

nonisolated struct FlexibleString: Decodable, Sendable {
    let value: String

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let string = try? c.decode(String.self) {
            value = string
        } else {
            value = String(try c.decode(Int.self))
        }
    }
}

/// Parses via string to avoid binary floating-point artefacts (e.g. 12.95 → 12.949999…).
nonisolated struct FlexibleDecimal: Decodable, Sendable {
    let value: Decimal

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        let raw = try (try? c.decode(String.self)) ?? String(c.decode(Double.self))
        let cleaned = raw.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "$", with: "")
        guard let decimal = Decimal(string: cleaned, locale: Locale(identifier: "en_US_POSIX")) else {
            throw DecodingError.dataCorruptedError(in: c, debugDescription: "Invalid decimal: \(raw)")
        }
        value = decimal
    }
}

/// Decodes an array, dropping elements that fail to decode instead of failing the whole response.
nonisolated struct LossyArray<Element: Decodable>: Decodable {
    let elements: [Element]

    init(from decoder: Decoder) throws {
        var c = try decoder.unkeyedContainer()
        var elements: [Element] = []
        while !c.isAtEnd {
            if let element = try c.decode(Failable.self).value { elements.append(element) }
        }
        self.elements = elements
    }

    private struct Failable: Decodable {
        let value: Element?
        init(from decoder: Decoder) throws { value = try? Element(from: decoder) }
    }
}
