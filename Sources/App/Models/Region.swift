import Vapor
import FluentProvider

final class Region: Model {
    static var entity = "regions"

    let storage = Storage()

    var id: Node?
    var shortName: String
    var fullName: String

    init(shortName: String, fullName: String) {
        self.shortName = shortName
        self.fullName = fullName
    }

    init(row: Row) throws {
        id = try row.get("id")
        shortName = try row.get("short_name")
        fullName = try row.get("full_name")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("id", id)
        try row.set("short_name", shortName)
        try row.set("full_name", fullName)
        return row
    }
}

extension Region: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "short_name": shortName,
            "full_name": fullName
        ])
    }
}

extension Region: ResponseRepresentable {
    func makeResponse() throws -> Response {
        var json = JSON()
        try json.set("id", id)
        try json.set("short_name", shortName)
        try json.set("full_name", fullName)
        return try json.makeResponse()
    }
}

// MARK: - Database Preparation

extension Region: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("short_name")
            builder.string("full_name")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Region {
    var accessories: Siblings<Region, Accessory, Pivot<Region, Accessory>> {
        return siblings()
    }
}
