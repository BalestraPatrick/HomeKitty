//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import HTTP

final class AccessoryController {

    var droplet: Droplet!

    func addRoutes(droplet: Droplet) {
        self.droplet = droplet
        let group = droplet.grouped("accessory")
        group.get(handler: accessory)
    }

    func accessory(request: Request) throws -> ResponseRepresentable {
        let query = request.query?["name"]?.string ?? ""
        let approvedAccessories = try Accessory.makeQuery().filter("approved", true)
        let accessories = try approvedAccessories.all()
        let accessory = try approvedAccessories.filter("name", query).first()
        let categories = try Category.all()
        let manufacturerCount = try Manufacturer.makeQuery().filter("approved", true).count()

        let node: Node

        if let accessory = accessory {
            let pageTitle = "Accessory Details"
            let pageIcon = (try? accessory.category.get()?.image) ?? ""
            node = try Node(node: [
                "accessory": accessory.makeNode(in: nil),
                "manufacturerSelected": true,
                "categories": categories.makeNode(in: nil),
                "accessories": accessories.makeNode(in: nil),
                "pageTitle": pageTitle.makeNode(in: nil),
                "pageIcon": pageIcon.makeNode(in: nil),
                "accessoryCount": accessories.count.makeNode(in: nil),
                "manufacturerCount": manufacturerCount.makeNode(in: nil),
                ])
        } else {
            node = try Node(node: [:])
        }
        return try droplet.view.make("accessory", node)
    }
}
