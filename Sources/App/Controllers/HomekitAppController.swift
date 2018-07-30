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
        router.get("apps", Int.parameter, use: app)
    }

    func apps(_ req: Request) throws -> Future<View> {
        let categories = try QueryHelper.categories(request: req)
        let manufacturerCount = try QueryHelper.manufacturerCount(request: req)
        let apps = try QueryHelper.apps(request: req)
        let accessoryCount = try QueryHelper.accessoriesCount(request: req)
        
        return flatMap(to: View.self, categories, manufacturerCount, apps, accessoryCount) { categories, manufacturersCount, apps, accessoryCount in
            let data = AppsResponse(apps: apps,
                                    categories: categories,
                                    accessoryCount: accessoryCount,
                                    manufacturerCount: manufacturersCount)
            let leaf = try req.make(LeafRenderer.self)
            return leaf.render("apps", data)
        }
    }

    func app(_ req: Request) throws -> Future<View> {
        let paramId: Int = try req.parameters.next()

        let categories = try QueryHelper.categories(request: req)
        let manufacturerCount = try QueryHelper.manufacturerCount(request: req)
        let app = try QueryHelper.app(request: req, id: paramId)
        let accessoryCount = try QueryHelper.accessoriesCount(request: req)

        return app.flatMap{ app in
            guard let app = app else { throw Abort(.badRequest) }
            return try ItunesApp.fetchItunesApp(req: req, appStoreId: app.appStoreId).flatMap { itunesApp in
                guard let itunesApp = itunesApp else { throw Abort(.badRequest) }

                return flatMap(to: View.self, categories, manufacturerCount, accessoryCount) { categories, manufacturersCount, accessoryCount in
                    let data = AppResponse(app: HomekitApp.HomekitAppResponse(itunesApp: itunesApp),
                                           categories: categories,
                                           accessoryCount: accessoryCount,
                                           manufacturerCount: manufacturersCount)
                    let leaf = try req.make(LeafRenderer.self)
                    return leaf.render("app", data)
                }
            }
        }
    }

    private struct AppsResponse: Codable {
        let apps: [HomekitApp]
        let categories: [Category]
        let accessoryCount: Int
        let manufacturerCount: Int
    }

    private struct AppResponse: Codable {
        let pageTitle = "App Details"
        let app: HomekitApp.HomekitAppResponse
        let categories: [Category]
        let accessoryCount: Int
        let manufacturerCount: Int
    }
}
