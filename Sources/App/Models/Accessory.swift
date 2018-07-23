//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class Accessory: PostgreSQLModel {

    static var entity = "accessories"

    var id: Int?
    var categoryId: Int
    var manufacturerId: Int
    var requiredHubId: Int?

    var name: String
    var image: String
    var price: String
    var productLink: String
    var amazonLink: String?
    var approved: Bool
    var released: Bool
    var date: Date
    var requiresHub: Bool
    var featured: Bool

    init(
        name: String,
        image: String,
        price: String,
        productLink: String,
        amazonLink: String?,
        categoryId: Int,
        manufacturerId: Int,
        released: Bool,
        requiresHub: Bool,
        requiredHubId: Int?) {
        self.name = name
        self.categoryId = categoryId
        self.manufacturerId = manufacturerId
        self.image = image
        self.price = price
        self.productLink = productLink
        self.amazonLink = amazonLink
        self.approved = false
        self.released = released
        self.date = Date()
        self.requiresHub = requiresHub
        self.requiredHubId = requiredHubId
        self.featured = false
    }

    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case manufacturerId = "manufacturer_id"
        case requiredHubId = "required_hub_id"

        case name
        case image
        case price
        case productLink = "product_link"
        case amazonLink = "amazon_link"
        case approved
        case released
        case date
        case requiresHub = "requires_hub"
        case featured
    }

    var category: Parent<Accessory, Category> {
        return parent(\Accessory.categoryId)
    }

    var manufacturer: Parent<Accessory, Manufacturer> {
        return parent(\Accessory.manufacturerId)
    }

    var requiredHub: Parent<Accessory, Accessory>? {
        return parent(\Accessory.requiredHubId)
    }
    
    var regions: Siblings<Accessory, Region, AccessoryRegionPivot> {
        return siblings()
    }

    func regionCompatibility(_ req: Request) throws -> Future<String> {
        return try regions.query(on: req).all().flatMap(to: String.self) { regions in
            let promise = req.eventLoop.newPromise(String.self)

            promise.succeed(result: regions.map { $0.name }.joined(separator: ", "))

            return promise.futureResult
        }
    }

    func didCreate(on connection: PostgreSQLConnection) throws -> EventLoopFuture<Accessory> {
        try updateCounterCache(connection)
        return Future.map(on: connection, { self })
    }

    func didUpdate(on connection: PostgreSQLConnection) throws -> EventLoopFuture<Accessory> {
        try updateCounterCache(connection)
        return Future.map(on: connection, { self })
    }
    func willDelete(on connection: PostgreSQLConnection) throws -> EventLoopFuture<Accessory> {
        try updateCounterCache(connection, willDelete: true)
        return Future.map(on: connection, { self })
    }

    func updateCounterCache(_ connection: PostgreSQLConnection, willDelete: Bool = false) throws {
        _ = category.get(on: connection).flatMap(to: Category.self, { category in
            return Category
                .query(on: connection)
                .filter(\Category.id == self.categoryId)
                .count()
                .flatMap(to: Category.self, { participationCount in
                    if !willDelete {
                        category.accessoriesCount = participationCount
                    } else {
                        category.accessoriesCount = participationCount - 1
                    }
                    return category.save(on: connection)
                })
        })
    }

    struct FeaturedResponse: Codable {
        let name: String
        let externalLink: String
        let bannerImage: String
    }

    struct AccessoryResponse: Codable {
        let id: Int?
        let name: String
        let image: String
        let price: String
        let productLink: String
        let categoryId: Int
        let amazonLink: String?
        let approved: Bool
        let released: Bool
        let date: Date
        let requiresHub: Bool
        let featured: Bool
        let manufacturerId: Int?
        let manufacturerName: String?
        let manufacturerWebsite: String?
        let timeAgo: String?

        init(accessory: Accessory, manufacturer: Manufacturer) {
            id = accessory.id
            name = accessory.name
            image = accessory.image
            price = accessory.price
            productLink = accessory.productLink
            categoryId = accessory.categoryId
            amazonLink = accessory.amazonLink
            approved = accessory.approved
            released = accessory.released
            date = accessory.date
            requiresHub = accessory.requiresHub
            featured = accessory.featured
            manufacturerId = accessory.manufacturerId
            manufacturerName = manufacturer.name
            manufacturerWebsite = manufacturer.websiteLink
            timeAgo = accessory.date.timeAgoString()
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case image
            case price
            case productLink = "product_link"
            case amazonLink = "amazon_link"
            case approved
            case released
            case date
            case requiresHub = "requires_hub"
            case featured
            case manufacturerId = "manufacturer_id"
            case manufacturerName = "manufacturer_name"
            case timeAgo = "time_ago"
            case manufacturerWebsite = "manufacturer_website"
            case categoryId = "category_id"
        }
    }
}

extension Accessory: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection, closure: { builder in
            builder.field(for: \Accessory.id, type: .integer, .primaryKey())
            builder.field(for: \Accessory.name)
            builder.field(for: \Accessory.image)
            builder.field(for: \Accessory.price)
            builder.field(for: \Accessory.productLink)
            builder.field(for: \Accessory.categoryId)
            builder.field(for: \Accessory.amazonLink)
            builder.field(for: \Accessory.approved)
            builder.field(for: \Accessory.released)
            builder.field(for: \Accessory.date)
            builder.field(for: \Accessory.requiresHub)
            builder.field(for: \Accessory.requiredHubId)
            builder.field(for: \Accessory.featured)
            builder.field(for: \Accessory.manufacturerId)
            builder.reference(from: \Accessory.requiredHubId, to: \Accessory.id)
            builder.reference(from: \Accessory.categoryId, to: \Category.id)
            builder.reference(from: \Accessory.manufacturerId, to: \Manufacturer.id)
        })
    }

    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.delete(self, on: connection)
    }
}
