//
//  Copyright © 2018 Kim de Vos. All rights reserved.
//

import Vapor
import HTTP
import FluentPostgreSQL
import Leaf
import FluentSQL

final class SearchController {

    init(router: Router) {
                router.get("search", use: search)
    }

    func search(_ req: Request) throws -> Future<View> {
        guard let search: String = try req.query.get(at: "term") else { throw Abort(.badRequest) }
        let categories = try QueryHelper.categories(request: req)
        let manufacturerCount = try QueryHelper.manufacturerCount(request: req)
        let accessoryCount = try QueryHelper.accessoriesCount(request: req)

        //            // Only search through accessory and manufacturer name.
        //            let accessories = try Accessory.makeQuery().filter("approved", true).sort("date", .descending).all().filter { accessory -> Bool in
        //                let manufacturerResult = try accessory.manufacturer.get()?.name.lowercased().contains(search) ?? false
        //                let nameResult = accessory.name.lowercased().contains(search)
        //                return manufacturerResult || nameResult
        //            }
        let accessories = try QueryHelper.accessories(request: req, searchQuery: search).all()

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