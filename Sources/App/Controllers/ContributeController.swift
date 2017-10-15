//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import HTTP

final class ContributeController {

    var droplet: Droplet!

    func addRoutes(droplet: Droplet) {
        self.droplet = droplet
        let group = droplet.grouped("contribute")
        group.get(handler: contribute)
        group.post("submit", handler: submit)
    }

    func contribute(request: Request) throws -> ResponseRepresentable {
        let manufacturers = try Manufacturer.makeQuery().filter("approved", true).sort("name", .ascending).all()
        let categories = try Category.makeQuery().sort("name", .ascending).all()
        let bridges = try Category.makeQuery().filter("name", "Bridges").first()?.accessories.all()
        let regions = try Region.makeQuery().sort("full_name", .ascending).all()

        let node = try Node(node: [
            "categories": categories.makeNode(in: nil),
            "manufacturers": manufacturers.makeNode(in: nil),
            "bridges": bridges.makeNode(in: nil),
            "regions": regions.makeNode(in: nil)
        ])
        return try droplet.view.make("contribute", node)
    }

    func submit(request: Request) throws -> ResponseRepresentable {
        var manufacturerId: Identifier?
        if let name = request.formURLEncoded?["manufacturer-name"]?.string,
            let website = request.formURLEncoded?["manufacturer-website"]?.string {
            // Create the manufacturer because it's a new one
            let manufacturer = Manufacturer(name: name, websiteLink: website)
            try manufacturer.save()
            manufacturerId = manufacturer.id
        } else if let manufacturerName = request.formURLEncoded?["manufacturer"]?.string, let category = try Manufacturer.makeQuery().filter("name", manufacturerName).first() {
            // Grab the exising manufacturer and store it for later assignment to the accessory.
            manufacturerId = category.id
        } else {
            return "Unrecognized manufacturer or error in creating it."
        }

        if let name = request.formURLEncoded?["name"]?.string,
            let price = request.formURLEncoded?["price"]?.string,
            let image = request.formURLEncoded?["image"]?.string,
            let link = request.formURLEncoded?["link"]?.string,
            let categoryName = request.formURLEncoded?["category"]?.string,
            let manufacturerId = manufacturerId {
                let released = request.formURLEncoded?["released"]?.bool ?? false
                let requiresHub = request.formURLEncoded?["requires_hub"]?.bool ?? false
                let requiredBridgeName = request.formURLEncoded?["required_bridge"]?.string
                let bridge = try Accessory.makeQuery().filter("name", requiredBridgeName).first()
                if let category = try Category.makeQuery().filter("name", categoryName).first() {
                    let accessory = Accessory(
                        name: name,
                        image: image,
                        price: price.normalizedPrice,
                        productLink: link,
                        categoryId: category.id!,
                        manufacturerId: manufacturerId,
                        released: released,
                        requiresHub: requiresHub,
                        requiredHubId: bridge?.id
                    )

                    try accessory.save()

                    if let regions = request.formURLEncoded?["regions"]?.array {
                        let regionsFullNames = regions.map { $0.string }
                        for regionFullName in regionsFullNames {
                            if let region = try Region.makeQuery().filter("full_name", regionFullName).first() {
                                try accessory.regions.add(region)
                            }
                        }
                    }
                }
        }
        let node = try Node(node: ["success": true])
        return try droplet.view.make("contribute", node)
    }
}
