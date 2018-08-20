//
//  HomeKitAppController.swift
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

final class HomeKitAppController {

    init(router: Router) {
        router.get("apps", use: apps)
        router.get("apps", Int.parameter, use: app)
        router.get("apps","contribute", use: contribute)
        router.post("apps","contribute", use: submit)
    }

    func apps(_ req: Request) throws -> Future<View> {
        let categories = try QueryHelper.categories(request: req)
        let manufacturerCount = try QueryHelper.manufacturerCount(request: req)
        let apps = try QueryHelper.apps(request: req)
        let accessoryCount = try QueryHelper.accessoriesCount(request: req)
        let appCount = try QueryHelper.appCount(request: req)
        
        return flatMap(to: View.self, categories, manufacturerCount, apps, accessoryCount, appCount) { categories, manufacturersCount, apps, accessoryCount, appCount in
            let data = AppsResponse(apps: apps,
                                    categories: categories,
                                    accessoryCount: accessoryCount,
                                    manufacturerCount: manufacturersCount,
                                    appCount: appCount)
            let leaf = try req.view()
            return leaf.render("Apps/apps", data)
        }
    }

    func app(_ req: Request) throws -> Future<View> {
        let paramId: Int = try req.parameters.next()

        let categories = try QueryHelper.categories(request: req)
        let manufacturerCount = try QueryHelper.manufacturerCount(request: req)
        let app = try QueryHelper.app(request: req, id: paramId)
        let accessoryCount = try QueryHelper.accessoriesCount(request: req)
        let appCount = try QueryHelper.appCount(request: req)

        return app.flatMap{ app in
            guard let app = app else { throw Abort(.badRequest) }

            return flatMap(to: View.self, categories, manufacturerCount, accessoryCount, appCount) { categories, manufacturersCount, accessoryCount, appCount in
                let data = AppResponse(app: app,
                                       categories: categories,
                                       accessoryCount: accessoryCount,
                                       manufacturerCount: manufacturersCount,
                                       appCount: appCount)
                let leaf = try req.view()
                return leaf.render("Apps/app", data)
            }
        }
    }

    func contribute(_ req: Request) throws -> Future<View> {
        let manufacturers = try QueryHelper.manufacturers(request: req)
        let categories = try QueryHelper.categories(request: req)
        let bridges = try QueryHelper.bridges(request: req)
        let regions = try QueryHelper.regions(request: req)

        return flatMap(to: View.self, manufacturers, categories, bridges, regions, { (manufacturers, categories, bridges, regions) in
            let data = ContributeResponse(categories: categories,
                                          manufacturers: manufacturers,
                                          bridges: bridges.map { Accessory.AccessoryResponse(accessory: $0.0, manufacturer: $0.1) },
                                          regions: regions)

            let leaf = try req.view()
            return leaf.render("Apps/contribute", data)
        })
    }

    func submit(_ req: Request) throws -> Future<View> {
        return try req.content.decode(ContributionRequest.self).flatMap { contributionRequest in
            return HomeKitApp.query(on: req)
                .filter(\HomeKitApp.appStoreLink == contributionRequest.appStoreLink).first()
                .flatMap{ app in
                    let leaf = try req.make(TemplateRenderer.self)

                    if app?.approved == false {
                        return leaf.render("contributeSuccess")
                    }

                    if app?.id != nil {
                        throw Abort(.badRequest, reason: "This app alrealy excist")
                    }

                    return HomeKitApp(name: contributionRequest.name,
                                      subtitle: contributionRequest.subtitle,
                                      price: Double(contributionRequest.price?.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: ".") ?? ""),
                                      appStoreLink: contributionRequest.appStoreLink,
                                      appStoreIcon: contributionRequest.appIcon,
                                      publisher: contributionRequest.publisher,
                                      publisherLink: contributionRequest.publisherLink)
                        .create(on: req)
                        .flatMap { _ in
                            return leaf.render("contributeSuccess")
                    }
            }
        }
    }

    struct ContributeResponse: Content {
        let categories: [Category]
        let manufacturers: [Manufacturer]
        let bridges: [Accessory.AccessoryResponse]
        let regions: [Region]
    }

    private struct AppsResponse: Codable {
        let apps: [HomeKitApp]
        let categories: [Category]
        let accessoryCount: Int
        let manufacturerCount: Int
        let appCount: Int
    }

    private struct AppResponse: Codable {
        let pageTitle = "App Details"
        let app: HomeKitApp
        let categories: [Category]
        let accessoryCount: Int
        let manufacturerCount: Int
        let appCount: Int
    }

    private struct ContributionRequest: Content {
        let name: String
        let subtitle: String?
        let price: String?
        let appIcon: String
        let appStoreLink: String
        let recaptchaResponse: String
        let publisher: String
        let publisherLink: String

        enum CodingKeys: String, CodingKey {
            case name
            case subtitle
            case price
            case appIcon = "app_icon"
            case appStoreLink = "appStore_link"
            case publisher
            case publisherLink = "publisher_link"
            case recaptchaResponse = "g-recaptcha-response"
        }

    }
}
