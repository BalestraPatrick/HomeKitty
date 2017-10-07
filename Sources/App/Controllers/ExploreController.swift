//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import HTTP

final class ExploreController {

    var droplet: Droplet!

    func addRoutes(droplet: Droplet) {
        self.droplet = droplet
        droplet.get("explore", handler: self.explore)
        let explore = droplet.grouped("explore")
        explore.get(handler: self.explore)
        let search = explore.grouped("search")
        search.get(handler: self.search)
    }

    func explore(request: Request) throws -> ResponseRepresentable {
        let queryCategory = request.query?["category"]?.string ?? ""
        let category = try Category.makeQuery().filter("name", queryCategory).first()

        // Get all categories and find out if one of them is selected.
        let categories = try Category.all().select(selected: queryCategory)

        let accessories: [Accessory]
        let pageTitle: String
        let pageIcon: String

        if let category = category {
            // Get all accessories for the selected category.
            accessories = try Accessory.makeQuery().filter("approved", true).filter("category_id", category.id!.string!).sort("date", .descending).all()
            pageTitle = category.name
            pageIcon = category.image
        } else {
            // Get all accessories because no category was selected.
            accessories = try Accessory.makeQuery().filter("approved", true).sort("date", .descending).all()
            pageTitle = "All Accessories"
            pageIcon = ""
        }

        let nodes = try Node(node: [
            "categories": categories.makeNode(in: nil),
            "accessories": accessories.makeNode(in: nil),
            "pageTitle": pageTitle.makeNode(in: nil),
            "pageIcon": pageIcon.makeNode(in: nil),
            "noAccessories": accessories.count == 0
        ])
        return try droplet.view.make("explore", nodes)
    }

    func search(request: Request) throws -> ResponseRepresentable {
        let search = request.query?["term"]?.string ?? ""

        // Only search through accessory and manufacturer name.
        let categories = try Category.all()
        let accessories = try Accessory.makeQuery().filter("approved", true).sort("date", .descending).all().filter { accessory -> Bool in
            let manufacturerResult = try accessory.manufacturer.get()?.name.lowercased().contains(search) ?? false
            let nameResult = accessory.name.lowercased().contains(search)
            return manufacturerResult || nameResult
        }
        let pageTitle = "Results for \"\(search)\""
        let pageIcon = ""

        let nodes = try Node(node: [
            "categories": categories.makeNode(in: nil),
            "accessories": accessories.makeNode(in: nil),
            "pageTitle": pageTitle.makeNode(in: nil),
            "pageIcon": pageIcon.makeNode(in: nil),
            "noAccessories": accessories.count == 0
        ])
        return try droplet.view.make("explore", nodes)
    }
}
