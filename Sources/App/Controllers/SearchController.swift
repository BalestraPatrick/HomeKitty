//
//  Copyright © 2018 HomeKitty. All rights reserved.
//

import Vapor
import HTTP
import FluentPostgreSQL
import Leaf
import FluentSQL

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
        let sidemenuCounts = QueryHelper.sidemenuCounts(request: req)

        let accessories = try QueryHelper.accessories(request: req)
            .group(PostgreSQLBinaryOperator.or, closure: { builder in
                builder.filter(PostgreSQLColumnIdentifier.keyPath(\Accessory.name), .ilike, "%\(search)%")
                builder.filter(PostgreSQLColumnIdentifier.keyPath(\Manufacturer.name), .ilike, "%\(search)%")
            })
            .all().map { accessories in
            return accessories.map { Accessory.AccessoryResponse(accessory: $0.0, manufacturer: $0.1) }
        }

        return flatMap(to: View.self, categories, accessories, sidemenuCounts, { (categories, accessories, sidemenuCounts) in
            let pageTitle: String
            if accessories.count == 1 {
                pageTitle = "\(accessories.count) result for \"\(search)\""
            } else {
                pageTitle = "\(accessories.count) results for \"\(search)\""
            }
            let data = SearchResponse(categories: categories,
                                      accessories: accessories,
                                      pageTitle: pageTitle,
                noAccessoriesFound: accessories.isEmpty,
                accessoryCount: sidemenuCounts.accessoryCount,
                manufacturerCount: sidemenuCounts.manufacturerCount,
                appCount: sidemenuCounts.appCount)

            let leaf = try req.view()
            return leaf.render("search", data)
        })
    }

    private struct SearchResponse: Codable {
        let categories: [Category]
        let accessories: [Accessory.AccessoryResponse]
        let pageTitle: String
        let noAccessoriesFound: Bool
        let accessoryCount: Int
        let manufacturerCount: Int
        let appCount: Int
    }
}
