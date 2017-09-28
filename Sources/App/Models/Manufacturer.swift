//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import FluentProvider

final class Manufacturer: Model {

    static var entity = "manufacturer"

    let storage = Storage()

    var id: Node?
    var name: String
    var websiteLink: String
    var approved = false

    var directLink: String {
        return "manufacturer?name=\(name)"
    }
    var accessories: Children<Manufacturer, Accessory> {
        return children()
    }

    init(name: String, websiteLink: String, approved: Bool = false) {
        self.name = name
        self.websiteLink = websiteLink
        self.approved = approved
    }

    init(row: Row) throws {
        id = try row.get("id")
        name = try row.get("name")
        websiteLink = try row.get("website_link")
        approved = try row.get("approved")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("id", id)
        try row.set("name", name)
        try row.set("website_link", websiteLink)
        try row.set("approved", approved)
        return row
    }
}

extension Manufacturer: NodeRepresentable {

    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "name": name,
            "website_link": websiteLink
        ])
    }
}

extension Manufacturer: ResponseRepresentable {

    func makeResponse() throws -> Response {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("website_link", websiteLink)
        try json.set("approved", approved)
        return try json.makeResponse()
    }
}

// MARK: - Database Preparation

extension Manufacturer: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("website_link")
            builder.bool("approved")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
