//
//  Copyright © 2018 HomeKitty. All rights reserved.
//

import Foundation
import FluentPostgreSQL
import Vapor
import FluentSQL

final class QueryHelper {

    static func categories(request req: Request) throws -> Future<[Category]> {
        return req.withPooledConnection(to: .psql) { db -> Future<[Category]> in
            return Category.query(on: db)
                .sort(\Category.name, .ascending)
                .all()
        }
    }

    // MARK: - Manufacturers
    static func manufacturerCount(request req: Request) throws -> Future<Int> {
        return req.withPooledConnection(to: .psql) { db -> Future<Int> in
            return Manufacturer.query(on: db)
                .filter(\Manufacturer.approved == true)
                .count()
        }
    }

    static func manufacturer(request req: Request, id: Int) throws -> Future<Manufacturer?> {
        return req.withPooledConnection(to: .psql) { db -> Future<Manufacturer?> in
            return Manufacturer.query(on: db)
                .filter(\Manufacturer.approved == true)
                .filter(\Manufacturer.id == id)
                .first()
        }
    }

    static func manufacturers(request req: Request) throws -> Future<[Manufacturer]> {
        return req.withPooledConnection(to: .psql) { db -> Future<[Manufacturer]> in
            return Manufacturer.query(on: db)
                .filter(\Manufacturer.approved == true)
                .sort(\Manufacturer.name, .ascending)
                .all()
        }
    }

    // MARK: - Accessories
    static func featuredAccessories(request req: Request) throws -> QueryBuilder<PostgreSQLDatabase, (Accessory, Manufacturer)> {
        return try accessories(request: req)
            .filter(\Accessory.featured == true)
    }

    static func accessoriesCount(request req: Request) throws -> Future<Int> {
        return req.withPooledConnection(to: .psql) { db -> Future<Int> in
            return Accessory.query(on: db)
                .filter(\Accessory.approved == true)
                .count()
        }
    }

    static func accessories(request req: Request, manufacturerId: Int? = nil, categoryId: Int? = nil) throws -> QueryBuilder<PostgreSQLDatabase, (Accessory, Manufacturer)> {
        // TODO: change this query to use the pool
        let query = Accessory.query(on: req)
            .join(\Manufacturer.id, to: \Accessory.manufacturerId, method: .inner)
            .sort(\Accessory.date, .descending)

        if let manufacturerId = manufacturerId {
            query.filter(\Accessory.manufacturerId == manufacturerId)
        }

        if let categoryId = categoryId {
            query.filter(\Accessory.categoryId == categoryId)
        }

        return query.filter(\Accessory.approved == true).alsoDecode(Manufacturer.self)
    }

    static func accessory(request req: Request, id: Int) throws -> Future<(Accessory, Manufacturer)?> {
        return req.withPooledConnection(to: .psql) { db -> Future<(Accessory, Manufacturer)?> in
            return try accessories(request: req)
                .filter(\Accessory.id == id)
                .first()
        }
    }

    static func bridges(request req: Request) throws -> Future<[(Accessory, Manufacturer)]> {
        return req.withPooledConnection(to: .psql) { db -> Future<[(Accessory, Manufacturer)]> in
            return Category.query(on: db)
                .filter(\Category.name == "Bridges").first()
                .flatMap(to: [(Accessory, Manufacturer)].self, { category  in
                    guard let category = category else { throw Abort(.internalServerError) }
                    return try QueryHelper.accessories(request: req, categoryId: category.id).all()
                })
        }
    }

    // MARK: - Regions
    static func regions(request req: Request) throws -> Future<[Region]> {
        return req.withPooledConnection(to: .psql) { db -> Future<[Region]> in
            return Region.query(on: db).sort(\Region.fullName, .ascending).all()
        }
    }

    static func region(request req: Request, id: Int) throws -> Future<Region?> {
        return req.withPooledConnection(to: .psql) { db -> Future<Region?> in
            return Region.query(on: db).sort(\Region.fullName, .ascending).filter(\Region.id == id).first()
        }
    }
}
