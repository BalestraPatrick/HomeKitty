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
    static func featuredAccessories(request req: Request) throws -> QueryBuilder<Accessory, (Accessory, Manufacturer)> {
        return try accessories(request: req)
            .filter(\Accessory.featured == true)
            .sort(\Accessory.date, .descending)
    }

    static func accessoriesCount(request req: Request) throws -> Future<Int> {
        return try Accessory.query(on: req)
            .filter(\Accessory.approved == true)
            .count()
    }

    static func accessories(request req: Request, manufacturerId: Int? = nil, categoryId: Int? = nil, searchQuery: String? = nil) throws -> QueryBuilder<Accessory, (Accessory, Manufacturer)> {
        let query = try Accessory.query(on: req)
            .join(field: \Manufacturer.id, to: \Accessory.manufacturerId, method: .outer)
            .sort(\Accessory.date, .descending)


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

        return try query.filter(Accessory.self, \Accessory.approved == true).alsoDecode(Manufacturer.self)
    }
    
//    static func findAccessories(request req: Request, searchQuery: String) throws -> Future<[Accessory.AccessoryResponse]> {
//        return req.requestPooledConnection(to: .psql)
//            .flatMap(to: [Accessory.AccessoryResponse].self) { connection in
//                return try connection.query("SELECT * FROM accessories JOIN manufacturer ON manufacturer.id = accessories.manufacturer_id WHERE LOWER(accessories.\"name\") LIKE '%\(searchQuery.lowercased())%' OR LOWER(manufacturer.\"name\") LIKE '%\(searchQuery.lowercased())%'")
//                    .flatMap(to: [Accessory.AccessoryResponse].self, { data -> EventLoopFuture<[Accessory.AccessoryResponse]> in
//                        let data = try data.map { row -> Accessory.AccessoryResponse in
//                            let genericData: [QueryField: PostgreSQLData] = row.reduce(into: [:]) { (row, cell) in
//                                row[QueryField(name: cell.key.name)] = cell.value
//                            }
//                            return try QueryDataDecode (PostgreSQLDatabase.self, entity: Accessory.entity).decode(Accessory.AccessoryResponse.self, from: genericData)
//                        }
//                        
//                        let promise = req.eventLoop.newPromise([Accessory.AccessoryResponse].self)
//                        promise.succeed(result: data)
//                        return promise.futureResult
//                    })
//        }
//    }

    static func accessory(request req: Request, id: Int) throws -> Future<(Accessory, Manufacturer)?> {
        return try accessories(request: req)
            .filter(\Accessory.id == id)
            .first()
    }

    static func bridges(request req: Request) throws -> Future<[(Accessory, Manufacturer)]> {
        return try Category.query(on: req)
            .filter(\Category.name == "Bridges").first()
            .flatMap(to: [(Accessory, Manufacturer)].self, { category  in
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


