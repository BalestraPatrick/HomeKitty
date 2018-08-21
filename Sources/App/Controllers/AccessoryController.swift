//
//  Copyright © HomeKitty. All rights reserved.
//

import Foundation
import Vapor
import HTTP
import FluentPostgreSQL
import Leaf
import Fluent
import SendGrid

final class AccessoryController {
    
    init(router: Router) {
        router.get("accessories", Int.parameter, use: accessory)
        router.get("accessories", Int.parameter, "report", use: report)
        router.post("accessories", Int.parameter, "report", use: submitReport)
        router.get("accessories", use: accessories)
        router.get("accessory", use: oldAccessory)
        router.get("accessories", "contribute", use: contribute)
        router.post("accessories", "contribute", use: submit)
    }
    
    func accessories(_ req: Request) throws -> Future<View> {
        let categories = try QueryHelper.categories(request: req)
        let sidemenuCounts = QueryHelper.sidemenuCounts(request: req)
        let accessories = try QueryHelper.accessories(request: req).all()

        return flatMap(to: View.self, categories, accessories, sidemenuCounts) { categories, accessories, sidemenuCounts in
            let data = AccessoriesResponse(noAccessoriesFound: accessories.isEmpty,
                accessories: accessories.map { Accessory.AccessoryResponse(accessory: $0.0, manufacturer: $0.1) },
                                           categories: categories,
                                           accessoryCount: sidemenuCounts.accessoryCount,
                                           appCount: sidemenuCounts.appCount,
                                           manufacturerCount: sidemenuCounts.manufacturerCount,
                                           accessoriesSelected: true)
            let leaf = try req.view()
            return leaf.render("Accessories/accessories", data)
        }
    }
    
    func accessory(_ req: Request) throws -> Future<View> {
        let paramId: Int = try req.parameters.next()
        
        let accessory = try QueryHelper.accessory(request: req, id: paramId)
        let categories = try QueryHelper.categories(request: req)
        let sidemenuCounts = QueryHelper.sidemenuCounts(request: req)

        return accessory.flatMap(to: View.self) { accessory in
            guard let accessory = accessory else { throw Abort(.notFound) }
            
            return flatMap(to: View.self, categories, sidemenuCounts) { (categories, sidemenuCounts) in
                return try accessory.0.regionCompatibility(req).flatMap { region in
                    let data = AccessoryResponse(pageIcon: categories.first(where: { $0.id == accessory.0.categoryId })?.image ?? "",
                                                 accessory: Accessory.AccessoryResponse(accessory: accessory.0, manufacturer: accessory.1),
                                                 regionCompatibility: region.isEmpty ? nil : region,
                                                 categories: categories,
                                                 accessoryCount: sidemenuCounts.accessoryCount,
                                                 appCount: sidemenuCounts.appCount,
                                                 manufacturerCount: sidemenuCounts.manufacturerCount)

                    let leaf = try req.view()
                    return leaf.render("Accessories/accessory", data)
                }
            }
        }
    }

    func oldAccessory(_ req: Request) throws -> Future<Response> {
        let paramName: String = try req.query.get(at: "name")
        return Accessory.query(on: req).filter(\Accessory.name == paramName).first().map { accessory in
            return req.redirect(to: "accessories/\(accessory?.id ?? -1)")
        }
    }

    // MARK: - Report

    func report(_ req: Request) throws -> Future<View> {
        let accessoryId: Int = try req.parameters.next()
        let accessories = try QueryHelper.accessories(request: req).all()
        let apps = try QueryHelper.apps(request: req)

        return flatMap(to: View.self, accessories, apps) { (accessories, apps) in
            guard let accessory = accessories.filter({ $0.0.id == accessoryId }).first else { throw Abort(.badRequest) }
            let leaf = try req.view()
            let responseData = ReportResponse(accessories: accessories.map { $0.0 },
                                              apps: apps,
                                              accessoryToReport: Accessory.AccessoryResponse(accessory: accessory.0, manufacturer: accessory.1),
                                              appToReport: nil)
            return leaf.render("report", responseData)
        }
    }

    func submitReport(_ req: Request) throws -> Future<View> {
        return try req.content.decode(ReportRequest.self).flatMap(to: View.self, { reportRequest in
            return try RecaptchaManager.verify(with: req, recaptchaResponse: reportRequest.recaptchaResponse).flatMap { result in
                let accessoryId: Int = try req.parameters.next()
                return Accessory.query(on: req).filter(\.id == accessoryId).first().flatMap { accessory in
                    // Recaptcha failed, simply redirect to the report page.
                    guard result else { return try self.report(req) }
                    // Create and send email.
                    return try EmailManager.sendEmail(with: reportRequest, req: req)
                }
            }
        })
    }

    // MARK: - Contribute
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
            return leaf.render("Accessories/contribute", data)
        })
    }

    func submit(_ req: Request) throws -> Future<View> {
        return try req.content.decode(ContributeRequest.self).flatMap(to: View.self, { contributionData in
            return try RecaptchaManager.verify(with: req, recaptchaResponse: contributionData.recaptchaResponse).flatMap { result in
                // Recaptcha failed, simply redirect to the contribute page.
                guard result else { return try self.contribute(req) }
                // Create new accessory and manufacturer if needed.
                if let manufacturerId = contributionData.manufacturerId {
                    return self.newAccessory(req, manufacturerId: manufacturerId, contributeData: contributionData)
                } else {
                    return try self.newManufacturer(req, contributeData: contributionData)
                }
            }
        })
    }

    // MARK: - Helpers

    private func newManufacturer(_ req: Request, contributeData: ContributeRequest) throws -> Future<View> {
        return try req.content.decode(ContributeManufactorerRequest.self).flatMap(to: View.self) { data in
            return Manufacturer(name: data.manufacturerName, websiteLink: data.manufacturerWebsite)
                .create(on: req)
                .flatMap(to: View.self) { manufacturer throws -> EventLoopFuture<View> in
                    guard let manufacturerId = manufacturer.id else { throw Abort.init(.internalServerError) }
                    return self.newAccessory(req, manufacturerId: manufacturerId, contributeData: contributeData)
            }
        }
    }

    private func newAccessory(_ req: Request, manufacturerId: Int, contributeData: ContributeRequest) -> Future<View> {
        return Accessory(name: contributeData.name,
                         image: contributeData.image,
                         price: contributeData.price.normalizedPrice,
                         productLink: contributeData.link,
                         amazonLink: nil,
                         categoryId: contributeData.category,
                         manufacturerId: manufacturerId,
                         released: contributeData.released ?? false,
                         requiresHub: contributeData.requiresBridge ?? false,
                         requiredHubId: contributeData.requiredBridge,
                         supportsAirplay2: contributeData.supportsAirplay2 ?? false)
            .create(on: req)
            .flatMap(to: View.self) { newAccessory in
                let leaf = try req.view()

                if let regions = contributeData.regions {
                    var futures = [Future<AccessoryRegionPivot>]()

                    try regions.forEach { regionId in
                        let future = try QueryHelper.region(request: req, id: regionId).flatMap(to: AccessoryRegionPivot.self, { region in
                            guard let region = region,
                                let accessoryId = newAccessory.id,
                                let regionId = region.id else { throw Abort(.internalServerError) }
                            let pivot = AccessoryRegionPivot()

                            pivot.accessoryId = accessoryId
                            pivot.regionId = regionId

                            return pivot.create(on: req)
                        })

                        futures.append(future)
                    }

                    return futures.flatMap(to: View.self, on: req, { _ in
                        return leaf.render("contributeSuccess")
                    })
                } else {
                    return leaf.render("contributeSuccess")
                }
        }
    }

    // MARK: - Private

    private struct AccessoryResponse: Codable {
        let pageTitle = "Accessory Details"
        let pageIcon: String
        let accessory: Accessory.AccessoryResponse
        let regionCompatibility: String?
        let categories: [Category]
        let accessoryCount: Int
        let appCount: Int
        let manufacturerCount: Int
    }
    
    private struct AccessoriesResponse: Codable {
        let noAccessoriesFound: Bool
        let accessories: [Accessory.AccessoryResponse]
        let categories: [Category]
        let accessoryCount: Int
        let appCount: Int
        let manufacturerCount: Int
        let accessoriesSelected: Bool
    }

    private struct ContributeResponse: Content {
        let categories: [Category]
        let manufacturers: [Manufacturer]
        let bridges: [Accessory.AccessoryResponse]
        let regions: [Region]
    }

    private struct ContributeManufactorerRequest: Content {
        let manufacturerName: String
        let manufacturerWebsite: String
    }

    private struct ContributeRequest: Content {
        let manufacturerId: Int?
        let name: String
        let image: String
        let price: String
        let link: String
        let category: Int
        let released: Bool?
        let requiresBridge: Bool?
        let requiredBridge: Int?
        let regions: [Int]?
        let supportsAirplay2: Bool?
        let recaptchaResponse: String

        enum CodingKeys: String, CodingKey {
            case manufacturerId
            case name
            case image
            case price
            case link
            case category
            case released
            case requiresBridge
            case requiredBridge
            case regions
            case supportsAirplay2
            case recaptchaResponse = "g-recaptcha-response"
        }
    }
}
