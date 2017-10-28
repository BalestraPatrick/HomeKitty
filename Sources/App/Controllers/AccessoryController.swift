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
        let queryAccessory = request.query?["name"]?.string ?? ""
        let accessories = try Accessory.makeQuery().filter("approved", true)
        let accessory = try accessories.filter("name", queryAccessory).first()
        let categories = try Category.all()
        let manufacturerCount = try Manufacturer.makeQuery().filter("approved", true).count()

        let node: Node

        if let accessory = accessory {
            let regions = try accessory.regions.all()
            let pageTitle = "Accessory Details"
            let pageIcon = ""
            node = try Node(node: [
                "accessory": accessory.makeNode(in: nil),
                "regions": regions.makeNode(in: nil),
                "manufacturerSelected": true,
                "categories": categories.makeNode(in: nil),
                "accessories": accessories.all().makeNode(in: nil),
                "pageTitle": pageTitle.makeNode(in: nil),
                "pageIcon": pageIcon.makeNode(in: nil),
                "accessoryCount": accessories.count().makeNode(in: nil),
                "manufacturerCount": manufacturerCount.makeNode(in: nil),
                ])
        } else {
            node = try Node(node: [:])
        }
        return try droplet.view.make("accessory", node)
    }
}
