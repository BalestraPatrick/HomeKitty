//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import FluentProvider

final class Category: Model {
    
    static var entity = "category"

    let storage = Storage()

    var id: Node?
    var name: String
    var image: String
    var selected = false

    var accessories: Children<Category, Accessory> {
        return children()
    }
    var accessoriesCount: Int {
        return (try? accessories.makeQuery().filter("approved", true).all().count) ?? 0
    }

    init(name: String, image: String) {
        self.name = name
        self.image = image
    }

    init(row: Row) throws {
        id = try row.get("id")
        name = try row.get("name")
        image = try row.get("image")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("id", id)
        try row.set("name", name)
        try row.set("image", image)
        try row.set("accessoriesCount", accessoriesCount)
        try row.set("selected", selected)
        return row
    }
}

extension Category: NodeRepresentable {

    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "name": name,
            "image": image,
            "accessoriesCount": accessoriesCount,
            "selected": selected,
        ])
    }
}

// MARK: - Database Preparation

extension Category: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(Category.self) { builder in
            builder.id()
            builder.string("name")
            builder.string("image")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Array where Element: Category {

    func select(selected: String?) -> [Element] {
        forEach { category in
            if let selected = selected, selected == category.name {
                category.selected = true
            }
        }
        return self
    }
}
