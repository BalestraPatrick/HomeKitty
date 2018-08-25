//
//  Copyright © 2018 HomeKitty. All rights reserved.
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
            .filter(\Accessory.featured == true)
    }

    static func accessories(request req: Request, manufacturerId: Int? = nil, categoryId: Int? = nil) throws -> QueryBuilder<PostgreSQLDatabase, (Accessory, Manufacturer)> {
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
        return try accessories(request: req)
            .filter(\Accessory.id == id)
            .first()
    }

    static func sidemenuCounts(request req: Request) -> Future<SideMenuCounts> {
        return req.withPooledConnection(to: .psql) { (connection: PostgreSQLDatabase.Connection) in
            let query = """
                    SELECT (SELECT COUNT(*) FROM accessories where accessories.approved = true) AS accessoryCount,
                           (SELECT COUNT(*) FROM manufacturer where manufacturer.approved = true) AS manufacturerCount,
                           (SELECT COUNT(*) FROM apps where apps.approved = true) AS appCount
                    FROM now()
                    """

            return connection.query(.raw(query, binds: [])).map(to: SideMenuCounts.self, { rows in
                return SideMenuCounts(accessoryCount: try rows.first?.firstValue(name: "accessorycount")?.decode(Int.self) ?? -1,
                                      manufacturerCount: try rows.first?.firstValue(name: "manufacturercount")?.decode(Int.self) ?? -1,
                                      appCount: try rows.first?.firstValue(name: "appcount")?.decode(Int.self) ?? -1)
            })
        }
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

    // MARK: - HomeKit apps
    static func apps(request req: Request) throws -> Future<[HomeKitApp]> {
        return HomeKitApp.query(on: req)
            .filter(\HomeKitApp.approved == true)
            .sort(\HomeKitApp.createdAt, .descending)
            .all()
    }

    static func app(request req: Request, id: Int) throws -> Future<HomeKitApp?> {
        return HomeKitApp.query(on: req)
            .filter(\HomeKitApp.id == id)
            .filter(\HomeKitApp.approved == true)
            .sort(\HomeKitApp.name)
            .first()
    }

    struct SideMenuCounts: Encodable {
        let accessoryCount: Int
        let manufacturerCount: Int
        let appCount: Int
    }
}
