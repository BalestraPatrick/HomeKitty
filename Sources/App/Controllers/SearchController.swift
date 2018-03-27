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

    //    func explore(_ req: Request) throws -> Future<String> {
    //        return Future<String>()
    //        let queryCategory = request.query?["category"]?.string ?? ""
    //        let category = try Category.makeQuery().filter("name", queryCategory).first()
    //
    //        // Get all categories and find out if one of them is selected.
    //        let categories = try Category.all().select(selected: queryCategory)
    //
    //        let accessories: [Accessory]
    //        let accessoryCount: Int
    //        let pageTitle: String
    //        let pageIcon: String
    //        let currentRoute: String
    //
    //        if let category = category {
    //            // Get all accessories for the selected category.
    //            let allAccessories = try Accessory.makeQuery().filter("approved", true).all()
    //            accessories = allAccessories.sorted(by: { $0.date.compare($1.date) == .orderedDescending }).filter({ accessory -> Bool in
    //                return accessory.categoryId == category.id!
    //            })
    //            accessoryCount = allAccessories.count
    //            pageTitle = category.name
    //            pageIcon = category.image
    //            currentRoute = "explore-search"
    //        } else {
    //            // Get all accessories because no category was selected.
    //
    //            accessories = try Accessory.makeQuery().filter("approved", true).sort("date", .descending).all()
    //            accessoryCount = accessories.count
    //            pageTitle = "All Accessories"
    //            pageIcon = ""
    //            currentRoute = "explore"
    //        }
    //
    //        let manufacturerCount = try Manufacturer.makeQuery().filter("approved", true).count()
    //
    //        let nodes = try Node(node: [
    //            "categories": categories.makeNode(in: nil),
    //            "accessories": accessories.makeNode(in: nil),
    //            "pageTitle": pageTitle.makeNode(in: nil),
    //            "pageIcon": pageIcon.makeNode(in: nil),
    //            "noAccessories": accessories.count == 0,
    //            "accessoryCount": accessoryCount.makeNode(in: nil),
    //            "manufacturerCount": manufacturerCount.makeNode(in: nil),
    //            "allAccessoriesSelected": true,
    //            "currentRoute": currentRoute.makeNode(in: nil)
    //        ])
    //        return try droplet.view.make("explore", nodes)
    //    }
    //
    func search(_ req: Request) throws -> Future<View> {
        guard let search: String = try req.query.get(at: "term") else { throw Abort(.badRequest) }
        let categories = try QueryHelper.categories(request: req)
        let manufacturerCount = try QueryHelper.manufacturerCount(request: req)
        let accessoryCount = try QueryHelper.accessoriesCount(request: req)

        //            let allAccessories = try Accessory.makeQuery().filter("approved", true).all()
        //            let accessoryCount = allAccessories.count
        //
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
