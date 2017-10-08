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
        let accessoryCount: Int
        let pageTitle: String
        let pageIcon: String
        let currentRoute: String

        if let category = category {
            // Get all accessories for the selected category.
            let allAccessories = try Accessory.makeQuery().filter("approved", true).all()
            accessories = allAccessories.sorted(by: { $0.date.compare($1.date) == .orderedDescending }).filter({ accessory -> Bool in
                return accessory.categoryId == category.id!
            })
            accessoryCount = allAccessories.count
            pageTitle = category.name
            pageIcon = category.image
            currentRoute = "explore-search"
        } else {
            // Get all accessories because no category was selected.

            accessories = try Accessory.makeQuery().filter("approved", true).sort("date", .descending).all()
            accessoryCount = accessories.count
            pageTitle = "All Accessories"
            pageIcon = ""
            currentRoute = "explore"
        }

        let manufacturerCount = try Manufacturer.makeQuery().filter("approved", true).count()

        let nodes = try Node(node: [
            "categories": categories.makeNode(in: nil),
            "accessories": accessories.makeNode(in: nil),
            "pageTitle": pageTitle.makeNode(in: nil),
            "pageIcon": pageIcon.makeNode(in: nil),
            "noAccessories": accessories.count == 0,
            "accessoryCount": accessoryCount.makeNode(in: nil),
            "manufacturerCount": manufacturerCount.makeNode(in: nil),
            "allAccessoriesSelected": true,
            "currentRoute": currentRoute.makeNode(in: nil)
        ])
        return try droplet.view.make("explore", nodes)
    }

    func search(request: Request) throws -> ResponseRepresentable {
        let search = request.query?["term"]?.string ?? ""

        let allAccessories = try Accessory.makeQuery().filter("approved", true).all()
        let accessoryCount = allAccessories.count

        // Only search through accessory and manufacturer name.
        let accessories = try Accessory.makeQuery().filter("approved", true).sort("date", .descending).all().filter { accessory -> Bool in
            let manufacturerResult = try accessory.manufacturer.get()?.name.lowercased().contains(search) ?? false
            let nameResult = accessory.name.lowercased().contains(search)
            return manufacturerResult || nameResult
        }

        let categories = try Category.all()

        let pageTitle = "Results for \"\(search)\""
        let pageIcon = ""
        let currentRoute = "search"

        let manufacturerCount = try Manufacturer.makeQuery().filter("approved", true).count()

        let nodes = try Node(node: [
            "categories": categories.makeNode(in: nil),
            "accessories": accessories.makeNode(in: nil),
            "pageTitle": pageTitle.makeNode(in: nil),
            "pageIcon": pageIcon.makeNode(in: nil),
            "noAccessories": accessories.count == 0,
            "accessoryCount": accessoryCount.makeNode(in: nil),
            "manufacturerCount": manufacturerCount.makeNode(in: nil),
            "currentRoute": currentRoute.makeNode(in: nil)
        ])
        return try droplet.view.make("explore", nodes)
    }
}
