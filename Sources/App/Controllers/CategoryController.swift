//
//  Created by Kim de Vos on 24/03/2018.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Leaf

final class CategoryController {

    init(router: Router) {
        router.get("categories", Int.parameter, use: manufacturer)
    }

    func manufacturer(_ req: Request) throws -> Future<View> {
        let param: Int = try req.parameter()

        let categories = try Category.query(on: req).sort(\Category.name, .ascending).all()
        let manufacturersCount =  Manufacturer.query(on: req).count()
        let accessoriesCount = try Accessory.query(on: req).filter(\Accessory.approved == true).count()

        return categories.flatMap(to: View.self, { categories in
            guard let category = categories.first(where: { $0.id == param }) else { throw Abort(.notFound) }

            let accessories = try category.accessories.query(on: req).filter(\Accessory.approved == true).all()

            return flatMap(to: View.self, manufacturersCount, accessories, accessoriesCount, { (manufacturersCount, accessories, accessoriesCount) in
                return try categories.compactMap { try $0.makeResponse(req) }.flatMap(to: View.self, on: req, { categories in
                    return try accessories.map { try $0.makeResponse(req) }.flatMap(to: View.self, on: req, { accessories in
                        let leaf = try req.make(LeafRenderer.self)
                        let responseData = CategoryResponse(category: category,
                                                                pageIcon: category.image,
                                                                accessoryCount: accessoriesCount,
                                                                manufacturerCount: manufacturersCount,
                                                                categories: categories,
                                                                accessories: accessories)

                        return leaf.render("manufacturer", responseData)
                    })
                })
            })
        })
    }

    struct CategoryResponse: Codable {
        let category: Category
        let pageIcon: String
        let accessoryCount: Int
        let manufacturerCount: Int
        let categories: [Category.CategoryResponse]
        let accessories: [Accessory.AccessoryResponse]
    }
}
