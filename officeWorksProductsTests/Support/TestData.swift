import Foundation
@testable import officeWorksProducts

enum TestData {
    static let laptop = Product(id: "1", name: "Laptop", description: "Fast laptop", price: 1000, category: "electronics")
    static let ring = Product(id: "2", name: "Gold Ring", description: "Shiny", price: 250, category: "jewelery")
    static let shirt = Product(id: "3", name: "Shirt", description: "Cotton shirt", price: 20, category: "men's clothing")
    static let dress = Product(id: "4", name: "Dress", description: "Summer dress", price: 60, category: "women's clothing")

    static let all = [laptop, ring, shirt, dress]
    static let featured = [laptop, ring]
    static let categories = ["men's clothing", "jewelery", "electronics", "women's clothing"]
}
