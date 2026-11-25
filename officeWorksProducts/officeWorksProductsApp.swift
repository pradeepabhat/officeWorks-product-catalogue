//
//  officeWorksProductsApp.swift
//  officeWorksProducts
//
//  Created by Pradeepa K on 24/11/26.
//

import SwiftUI

@main
struct officeWorksProductsApp: App {
    private let repository: any CatalogRepositoryProtocol = RemoteCatalogRepository(client: APIClient())

    var body: some Scene {
        WindowGroup {
            MainTabView(repository: repository)
        }
    }
}
