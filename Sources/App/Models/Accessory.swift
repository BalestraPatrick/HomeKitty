//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import FluentProvider

final class Accessory: Model {

    static var entity = "accessories"

    let storage = Storage()
    
    var id: Node?
    var categoryId: Identifier
    var manufacturerId: Identifier
    var requiredHubId: Identifier?

    var name: String
    var image: String
    var price: String
    var productLink: String
    var amazonLink: String?
    var approved: Bool
    var released: Bool
    var date: Date
    var requiresHub: Bool

    init(
        name: String,
        image: String,
        price: String,
        productLink: String,
        amazonLink: String?,
        categoryId: Identifier,
        manufacturerId: Identifier,
        released: Bool = true,
        approved: Bool = false,
        date: Date = Date(),
        requiresHub: Bool = false,
        requiredHubId: Identifier?
    ) {
        self.name = name
        self.categoryId = categoryId
        self.manufacturerId = manufacturerId
        self.image = image
        self.price = price
        self.productLink = productLink
        self.amazonLink = amazonLink
        self.approved = approved
        self.released = released
        self.date = date
        self.requiresHub = requiresHub
        self.requiredHubId = requiredHubId
    }

    init(row: Row) throws {
        id = try row.get("id")
        name = try row.get("name")
        categoryId = try row.get("category_id")
        manufacturerId = try row.get("manufacturer_id")
        image = try row.get("image")
        price = try row.get("price")
        productLink = try row.get("product_link")
        amazonLink = try row.get("amazon_link")
        approved = try row.get("approved")
        released = try row.get("released")
        date = try row.get("date")
        requiresHub = try row.get("requires_hub")
        requiredHubId = try row.get("required_hub_id")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("id", id)
        try row.set("name", name)
        try row.set("category_id", categoryId)
        try row.set("manufacturer_id", manufacturerId)
        try row.set("image", image)
        try row.set("price", price)
        try row.set("product_link", productLink)
        try row.set("amazon_link", amazonLink)
        try row.set("approved", approved)
        try row.set("released", released)
        try row.set("date", date)
        try row.set("requires_hub", requiresHub)
        try row.set("required_hub_id", requiredHubId)
        return row
    }
}

extension Accessory {

    var category: Parent<Accessory, Category> {
        return parent(id: categoryId)
    }

    var manufacturer: Parent<Accessory, Manufacturer> {
        return parent(id: manufacturerId)
    }

    var requiredHub: Parent<Accessory, Accessory>? {
        return parent(id: requiredHubId)
    }

    var regions: Siblings<Accessory, Region, Pivot<Accessory, Region>> {
        return siblings()
    }

    var regionCompatibility: String? {
        let regionNames = try? regions.all().map { $0.name }
        if let regions = regionNames, !regions.isEmpty {
            return regions.joined(separator: ", ")
        }
        return nil
    }
}

extension Accessory: NodeRepresentable {

    func makeNode(in context: Context?) throws -> Node {
        var node = try Node(node: [
            "name": name,
            "category_id": categoryId.string!,
            "image": image,
            "price": price,
            "product_link": productLink,
            "released": released,
            "date": date,
            "requires_hub": requiresHub,
            "page_link": "/accessory?name=\(name)"
        ])

        if let manufacturer = try manufacturer.get() {
            node["manufacturer"] = manufacturer.name.makeNode(in: nil)
            node["manufacturer_link"] = manufacturer.directLink.makeNode(in: nil)
            node["manufacturer_website"] = manufacturer.websiteLink.makeNode(in: nil)
        }
        if let hub = try requiredHub?.get(), let hubId = hub.id {
            node["required_hub_id"] = hubId.string?.makeNode(in: nil)
            node["required_hub_page_link"] = "/accessory?name=\(hub.name)".makeNode(in: nil)
        }
        if let region = regionCompatibility {
            node["region_compatibility"] = region.makeNode(in: nil)
        }
        if let amazon = amazonLink {
            node["amazon_link"] = amazon.makeNode(in: nil)
        }
        return node
    }
}

extension Accessory: ResponseRepresentable {

    func makeResponse() throws -> Response {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("category_id", categoryId)
        try json.set("manufacturer_id", manufacturerId)
        try json.set("image", image)
        try json.set("price", price)
        try json.set("product_link", productLink)
        try json.set("amazon_link", amazonLink)
        try json.set("released", released)
        try json.set("approved", approved)
        try json.set("date", date)
        try json.set("requires_hub", requiresHub)
        try json.set("required_hub_id", requiredHubId)
        return try json.makeResponse()
    }
}

extension Accessory: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(Category.self)
            builder.parent(Manufacturer.self)
            builder.string("name")
            builder.string("image")
            builder.string("price")
            builder.string("product_link")
            builder.string("amazon_link")
            builder.bool("approved")
            builder.bool("released")
            builder.date("date")
            builder.bool("requires_hub")
            builder.parent(Accessory.self, optional: true, unique: false, foreignIdKey: "required_hub_id")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(Accessory.self)
    }
}
