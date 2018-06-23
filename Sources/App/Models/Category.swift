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
    var accessoriesCount: Int = 0

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
        case accessoriesCount = "accessories_count"
    }

    var accessories: Children<Category, Accessory> {
        return children(\Accessory.categoryId)
    }

    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}

// MARK: - Database Preparation

extension Category: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection, closure: { builder in
            builder.field(for: \Category.id, isIdentifier: true)
            builder.field(for: \Category.name)
            builder.field(for: \Category.image)
            builder.field(for: \Category.accessoriesCount)
        })
    }

    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.delete(self, on: connection)
    }
}
