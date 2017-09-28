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
        group.get(handler: explore)
        group.post("submit", handler: submit)
    }

    func explore(request: Request) throws -> ResponseRepresentable {
        let manufacturers = try Manufacturer.makeQuery().filter("approved", true).all().sorted(by: {  $0.name.localizedCompare($1.name) == .orderedAscending })
        let categories = try Category.all().sorted(by: {  $0.name.localizedCompare($1.name) == .orderedAscending })
        let node = try Node(node: [
            "categories": categories.makeNode(in: nil),
            "manufacturers": manufacturers.makeNode(in: nil)
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
            let manufacturer = manufacturerId {
                if let category = try Category.makeQuery().filter("name", categoryName).first() {
                    let accessory = Accessory(name: name, image: image, price: price.normalizedPrice, productLink: link, category: category.id!, manufacturer: manufacturer)
                    try accessory.save()
                }
        }
        let node = try Node(node: ["success": true])
        return try droplet.view.make("contribute", node)
    }
}
