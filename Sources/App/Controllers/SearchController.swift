//
//  Copyright © 2018 HomeKitty. All rights reserved.
//

import Vapor
import HTTP
import FluentPostgreSQL
import Leaf
import FluentSQL
import FluentQuery

final class SearchController {

    struct Result: Codable {
        var accessory: Accessory
        var manufacturer: Manufacturer
    }

    init(router: Router) {
        router.get("search", use: search)
    }

    func search(_ req: Request) throws -> Future<View> {
        guard let search: String = try req.query.get(at: "term") else { throw Abort(.badRequest) }
        let categories = try QueryHelper.categories(request: req)
        let manufacturerCount = try QueryHelper.manufacturerCount(request: req)
        let accessoryCount = try QueryHelper.accessoriesCount(request: req)

        let accessories = req.databaseConnection(to: .psql).flatMap { connection -> Future<[Accessory.AccessoryResponse]> in
            return try FluentQuery()
                .select(all: Accessory.self)
                .select(.row(Accessory.self), as: "accessory")
                .select(.row(Manufacturer.self), as: "manufacturer")
                .where(FQWhere(\Accessory.name %% search).and(\Accessory.approved == true).or(\Manufacturer.name %% search).and(\Manufacturer.approved == true))
                .join(FQJoinMode.left, Manufacturer.self, where: FQWhere(\Accessory.manufacturerId == \Manufacturer.id))
                .from(Accessory.self)
                .execute(on: connection)
                .decode(Result.self)
                .map { $0.map { Accessory.AccessoryResponse(accessory: $0.accessory, manufacturer: $0.manufacturer) } }
        }

        return flatMap(to: View.self, manufacturerCount, accessoryCount, categories, accessories, { (manufacturerCount, accessoryCount, categories, accessories) in
            let data = SearchResponse(categories: categories,
                                      accessories: accessories,
                                      pageTitle: "Results for \"\(search)\"",
                noAccessories: accessories.isEmpty,
                accessoryCount: accessoryCount,
                manufacturerCount: manufacturerCount)

            let leaf = try req.make(LeafRenderer.self)
            return leaf.render("search", data)
        })
    }

    private struct SearchResponse: Codable {
        let categories: [Category]
        let accessories: [Accessory.AccessoryResponse]
        let pageTitle: String
        let noAccessories: Bool
        let accessoryCount: Int
        let manufacturerCount: Int
    }
}
