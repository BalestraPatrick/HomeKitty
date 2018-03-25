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

    var directLink: String {
        guard let id = id else { return "error" }
        return "manufacturers/\(id)"
    }
    
//    var accessories: Children<Manufacturer, Accessory> {
//        return children()
//    }

    init(name: String, websiteLink: String, approved: Bool = false) {
        self.name = name
        self.websiteLink = websiteLink
        self.approved = approved
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
            try! builder.field(type: Database.fieldType(for: Int.self), for: \Manufacturer.id, isOptional: false, isIdentifier: true)
            try! builder.field(for: \Manufacturer.name)
            try! builder.field(for: \Manufacturer.websiteLink)
            try! builder.field(for: \Manufacturer.approved)
        })
    }

    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.delete(self, on: connection)
    }


}
