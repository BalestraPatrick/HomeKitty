//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import Fluent
import FluentPostgreSQL

final class Category: PostgreSQLModel {

    static var entity = "category"

    var id: Int?
    var name: String
    var image: String

    var accessories: Children<Category, Accessory> {
        return children(\Accessory.categoryId)
    }

    func accessoriesCount(on req: Request) throws -> Future<Int> {
        return try accessories.query(on: req).filter(\Accessory.approved == true).count()
    }

    func makeResponse(_ req: Request) throws -> Future<CategoryResponse> {
        return try accessoriesCount(on: req).flatMap(to: CategoryResponse.self) { accessoriesCount in
            let promise = req.eventLoop.newPromise(CategoryResponse.self)

            promise.succeed(result: CategoryResponse(id: self.id,
                                                     name: self.name,
                                                     image: self.image,
                                                     accessoriesCount: accessoriesCount))

            return promise.futureResult
        }
    }

    init(name: String, image: String) {
        self.name = name
        self.image = image
    }

    struct CategoryResponse: Content {
        let id: Int?
        let name: String
        let image: String
        let accessoriesCount: Int
    }
}

// MARK: - Database Preparation

extension Category: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection, closure: { builder in
            try! builder.field(type: Database.fieldType(for: Int.self), for: \Category.id, isOptional: false, isIdentifier: true)
            try! builder.field(for: \Category.name)
            try! builder.field(for: \Category.image)
        })
    }

    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.delete(self, on: connection)
    }
}
