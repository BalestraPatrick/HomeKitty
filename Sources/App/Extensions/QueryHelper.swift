//
//  Created by Kim de Vos on 27/03/2018.
//

import Foundation
import FluentPostgreSQL
import Vapor
import FluentSQL

final class QueryHelper {
    static func categories(request req: Request) throws -> Future<[Category]> {
        return try Category.query(on: req)
            .sort(\Category.name, .ascending)
            .all()
    }

    // MARK: - Manufacturers
    static func manufacturerCount(request req: Request) throws -> Future<Int> {
        return try Manufacturer.query(on: req)
            .filter(\Manufacturer.approved == true)
            .count()
    }

    static func manufacturer(request req: Request, id: Int) throws -> Future<Manufacturer?> {
        return try Manufacturer.query(on: req)
            .filter(\Manufacturer.approved == true)
            .filter(\Manufacturer.id == id)
            .first()
    }

    static func manufacturers(request req: Request) throws -> Future<[Manufacturer]> {
        return try Manufacturer.query(on: req)
            .filter(\Manufacturer.approved == true)
            .sort(\Manufacturer.name, .ascending)
            .all()
    }

    // MARK: - Accessories
    static func featuredAccessories(request req: Request) throws -> QueryBuilder<Accessory, Accessory.AccessoryResponse> {
        return try accessories(request: req)
            .filter(\Accessory.featured == true)
            .sort(\Accessory.date, .descending)
    }

    static func accessoriesCount(request req: Request) throws -> Future<Int> {
        return try Accessory.query(on: req)
            .filter(\Accessory.approved == true)
            .count()
    }

    static func accessories(request req: Request, manufacturerId: Int? = nil, categoryId: Int? = nil, searchQuery: String? = nil) throws -> QueryBuilder<Accessory, Accessory.AccessoryResponse> {
        let query = try Accessory.query(on: req)
            .join(field: \Manufacturer.id, to: \Accessory.manufacturerId, method: .outer)
            .customSQL{ query in
                query.statement = .select

                query.columns = [DataColumn(table: Accessory.entity, name: "name"),
                                 DataColumn(table: Accessory.entity, name: "image"),
                                 DataColumn(table: Accessory.entity, name: "id"),
                                 DataColumn(table: Accessory.entity, name: "price"),
                                 DataColumn(table: Accessory.entity, name: "product_link"),
                                 DataColumn(table: Accessory.entity, name: "amazon_link"),
                                 DataColumn(table: Accessory.entity, name: "approved"),
                                 DataColumn(table: Accessory.entity, name: "released"),
                                 DataColumn(table: Accessory.entity, name: "date"),
                                 DataColumn(table: Accessory.entity, name: "category_id"),
                                 DataColumn(table: Accessory.entity, name: "manufacturer_id"),
                                 DataColumn(table: Accessory.entity, name: "requires_hub"),
                                 DataColumn(table: Accessory.entity, name: "featured")]
                query.computed = [DataComputed(function: "trim", columns: [DataColumn(table: Manufacturer.entity, name: "name")], key: "manufacturer_name"),
                                  DataComputed(function: "trim", columns: [DataColumn(table: Manufacturer.entity, name: "website_link")], key: "manufacturer_website")]
            }
            .sort(\Accessory.date, .descending)
            .decode(Accessory.AccessoryResponse.self)

        if let manufacturerId = manufacturerId {
            try query.filter(\Accessory.manufacturerId == manufacturerId)
        }

        if let categoryId = categoryId {
            try query.filter(\Accessory.categoryId == categoryId)
        }

        if let searchQuery: String = searchQuery {
            try query.group(.or, closure: { builder in
                try builder.filter(\Accessory.name ~~ searchQuery)
                try builder.filter(Manufacturer.self, \Manufacturer.name ~~ searchQuery)
            })
        }

        return try query.filter(Accessory.self, \Accessory.approved == true)
    }

    static func accessory(request req: Request, id: Int) throws -> Future<Accessory.AccessoryResponse?> {
        return try accessories(request: req)
            .filter(\Accessory.id == id)
            .decode(Accessory.AccessoryResponse.self)
            .first()
    }

    static func bridges(request req: Request) throws -> Future<[Accessory.AccessoryResponse]> {
        return try Category.query(on: req)
            .filter(\Category.name == "Bridges").first()
            .flatMap(to: [Accessory.AccessoryResponse].self, { category  in
                guard let category = category else { throw Abort(.internalServerError) }

                return try QueryHelper.accessories(request: req, categoryId: category.id).all()
            })
    }

    // MARK: - Regions
    static func regions(request req: Request) throws -> Future<[Region]> {
        return try Region.query(on: req).sort(\Region.fullName, .ascending).all()
    }
    
    static func region(request req: Request, id: Int) throws -> Future<Region?> {
        return try Region.query(on: req).sort(\Region.fullName, .ascending).filter(\Region.id == id).first()
    }
}


