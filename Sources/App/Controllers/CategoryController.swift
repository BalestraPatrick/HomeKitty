//
//  Copyright © 2018 HomeKitty. All rights reserved.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Leaf

final class CategoryController {
    
    init(router: Router) {
        router.get("categories", Int.parameter, use: categories)
        router.get("explore", use: oldExplore)
    }
    
    func categories(_ req: Request) throws -> Future<View> {
        let param: Int = try req.parameters.next()
        
        let categories = try QueryHelper.categories(request: req)
        let sidemenuCounts = QueryHelper.sidemenuCounts(request: req)
        
        return categories.flatMap(to: View.self, { categories in
            guard let category = categories.first(where: { $0.id == param }) else { throw Abort(.notFound) }
            
            let accessories = try QueryHelper.accessories(request: req, categoryId: category.id).all()
            return flatMap(to: View.self, accessories, sidemenuCounts, { (accessories, sidemenuCounts) in
                let leaf = try req.view()
                let selectedCategoryIndex = param
                let responseData = CategoryResponse(noAccessoryFound: accessories.isEmpty,
                                                    selectedCategory: selectedCategoryIndex,
                                                    category: category,
                                                    pageIcon: category.image,
                                                    accessoryCount: sidemenuCounts.accessoryCount,
                                                    manufacturerCount: sidemenuCounts.manufacturerCount,
                                                    appCount: sidemenuCounts.appCount,
                                                    categories: categories,
                                                    accessories: accessories.map { Accessory.AccessoryResponse(accessory: $0.0, manufacturer: $0.1) })
                return leaf.render("categories", responseData)
            })
        })
    }

    func oldExplore(_ req: Request) throws -> Future<Response> {
        let paramName: String = try req.query.get(at: "category")
        return Category.query(on: req).filter(\Category.name == paramName).first().map { category in
            return req.redirect(to: "categories/\(category?.id ?? -1)")
        }
    }

    struct CategoryResponse: Codable {
        let noAccessoryFound: Bool
        let selectedCategory: Int
        let category: Category
        let pageIcon: String
        let accessoryCount: Int
        let manufacturerCount: Int
        let appCount: Int
        let categories: [Category]
        let accessories: [Accessory.AccessoryResponse]
    }
}
