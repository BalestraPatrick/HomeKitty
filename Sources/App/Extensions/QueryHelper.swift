//
//  Created by Kim de Vos on 27/03/2018.
//

import Foundation
import FluentPostgreSQL
import Vapor
import FluentSQL

final class QueryHelper {
    static func categories(request req: Request) throws -> Future<[Category]> {
        return Category.query(on: req)
            .sort(\Category.name, .ascending)
            .all()
    }

    // MARK: - Manufacturers
    static func manufacturerCount(request req: Request) throws -> Future<Int> {
        return Manufacturer.query(on: req)
            .filter(\Manufacturer.approved == true)
            .count()
    }

    static func manufacturer(request req: Request, id: Int) throws -> Future<Manufacturer?> {
        return Manufacturer.query(on: req)
            .filter(\Manufacturer.approved == true)
            .filter(\Manufacturer.id == id)
            .first()
    }

    static func manufacturers(request req: Request) throws -> Future<[Manufacturer]> {
        return Manufacturer.query(on: req)
            .filter(\Manufacturer.approved == true)
            .sort(\Manufacturer.name, .ascending)
            .all()
    }

    // MARK: - Accessories
    static func featuredAccessories(request req: Request) throws -> QueryBuilder<PostgreSQLDatabase, (Accessory, Manufacturer)> {
        return try accessories(request: req)
//            .sort(\Accessory.date, PostgreSQLDirection.descending)
//            .sort(\Accessory.date, .descending)
    }

    static func accessoriesCount(request req: Request) throws -> Future<Int> {
        return Accessory.query(on: req)
            .filter(\Accessory.approved == true)
            .count()
    }

    static func accessories(request req: Request, manufacturerId: Int? = nil, categoryId: Int? = nil, searchQuery: String? = nil) throws -> QueryBuilder<PostgreSQLDatabase, (Accessory, Manufacturer)> {
        let query = Accessory.query(on: req)
            .join(\Manufacturer.id, to: \Accessory.manufacturerId, method: .inner)
            .sort(\Accessory.date, .descending)

        if let manufacturerId = manufacturerId {
            query.filter(\Accessory.manufacturerId == manufacturerId)
        }

        if let categoryId = categoryId {
            query.filter(\Accessory.categoryId == categoryId)
        }

//        if let searchQuery: String = searchQuery {
//            try query.group(.or, closure: { builder in
//                builder.filter(\Accessory.name ~~ searchQuery)
//                builder.filter(Manufacturer.self, \Manufacturer.name ~~ searchQuery)
//            })
//        }

        return query.filter(\Accessory.approved == true).alsoDecode(Manufacturer.self)
    }

    static func accessory(request req: Request, id: Int) throws -> Future<(Accessory, Manufacturer)?> {
        return try accessories(request: req)
            .filter(\Accessory.id == id)
            .first()
    }

    static func bridges(request req: Request) throws -> Future<[(Accessory, Manufacturer)]> {
        return Category.query(on: req)
            .filter(\Category.name == "Bridges").first()
            .flatMap(to: [(Accessory, Manufacturer)].self, { category  in
                guard let category = category else { throw Abort(.internalServerError) }

                return try QueryHelper.accessories(request: req, categoryId: category.id).all()
            })
    }

    // MARK: - Regions
    static func regions(request req: Request) throws -> Future<[Region]> {
        return Region.query(on: req).sort(\Region.fullName, .ascending).all()
    }
    
    static func region(request req: Request, id: Int) throws -> Future<Region?> {
        return Region.query(on: req).sort(\Region.fullName, .ascending).filter(\Region.id == id).first()
    }
}


