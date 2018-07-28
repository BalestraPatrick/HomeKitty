//
//  Copyright © 2018 HomeKitty. All rights reserved.
//

import Vapor
import HTTP
import Leaf
import FluentPostgreSQL

final class ContributeController {
    
    init(router: Router) {
        router.get("contribute", use: contribute)
        router.post("contribute", use: submit)
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

            let leaf = try req.make(LeafRenderer.self)
            return leaf.render("contribute", data)
        })
    }
    
    func submit(_ req: Request) throws -> Future<View> {
        guard let recaptchaSecret = Environment.get("recaptcha_secret") else { fatalError("Missing recaptcha secret") }

        return try req.content.decode(ContributeRequest.self).flatMap(to: View.self, { contributionData in
            let client = try req.client()
            return client.post("https://www.google.com/recaptcha/api/siteverify?secret=\(recaptchaSecret)&response=\(contributionData.recaptchaResponse)")
                .flatMap { response in
                    return try response.content.decode(RecaptchaResponse.self)
                        .flatMap { recaptchaResponse in
                            guard recaptchaResponse.success else { throw Abort(.badRequest) }
                            if let manufacturerId = contributionData.manufacturerId {
                                return self.newAccessory(req, manufacturerId: manufacturerId, contributeData: contributionData)
                            } else {
                                return try self.newManufacturer(req, contributeData: contributionData)
                            }
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
                         requiredHubId: contributeData.requiredBridge)
            .create(on: req)
            .flatMap(to: View.self) { newAccessory in
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
                        let leaf = try req.make(LeafRenderer.self)
                        return leaf.render("contribute", ["success": true])
                    })
                } else {
                    let leaf = try req.make(LeafRenderer.self)
                    return leaf.render("contribute", ["success": true])
                }
        }
    }

    struct ContributeResponse: Content {
        let categories: [Category]
        let manufacturers: [Manufacturer]
        let bridges: [Accessory.AccessoryResponse]
        let regions: [Region]
    }

    struct ContributeManufactorerRequest: Content {
        let manufacturerName: String
        let manufacturerWebsite: String
    }

    struct ContributeRequest: Content {
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
            case recaptchaResponse = "g-recaptcha-response"
        }
    }

    struct RecaptchaResponse: Content {
        let success: Bool
    }
}
