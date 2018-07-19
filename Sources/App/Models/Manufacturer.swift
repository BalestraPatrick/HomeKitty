//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import FluentPostgreSQL

final class Manufacturer: PostgreSQLModel {

    static var entity = "manufacturer"

    var id: Int?
    var name: String
    var websiteLink: String
    var approved = false

    init(name: String, websiteLink: String) {
        self.name = name
        self.websiteLink = websiteLink
        self.approved = false
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case websiteLink = "website_link"
        case approved
    }
}

// MARK: - Database Migration

extension Manufacturer: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection, closure: { builder in
            builder.field(for: \Manufacturer.id, isIdentifier: false)
            builder.field(for: \Manufacturer.name)
            builder.field(for: \Manufacturer.websiteLink)
            builder.field(for: \Manufacturer.approved)
        })
    }

    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.delete(self, on: connection)
    }


}
