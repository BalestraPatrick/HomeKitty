//
//  HomekitAppController.swift
//  App
//
//  Created by Kim de Vos on 29/07/2018.
//

import Foundation
import Vapor
import HTTP
import FluentPostgreSQL
import Leaf
import Fluent

final class HomekitAppController {

    init(router: Router) {
        router.get("apps", use: apps)
    }

    func apps(_ req: Request) throws -> Future<View> {
        let categories = try QueryHelper.categories(request: req)
        let manufacturerCount = try QueryHelper.manufacturerCount(request: req)
        let apps = try QueryHelper.apps(request: req)
        let accessoryCount = try QueryHelper.accessoriesCount(request: req)
        
        return flatMap(to: View.self, categories, manufacturerCount, apps, accessoryCount) { categories, manufacturersCount, apps, accessoryCount in
            let data = AccessoriesResponse(apps: apps,
                                           categories: categories,
                                           accessoryCount: accessoryCount,
                                           manufacturerCount: manufacturersCount)
            let leaf = try req.make(LeafRenderer.self)
            return leaf.render("apps", data)
        }
    }

    private struct AccessoriesResponse: Codable {
        let apps: [HomekitApp]
        let categories: [Category]
        let accessoryCount: Int
        let manufacturerCount: Int
    }
}
