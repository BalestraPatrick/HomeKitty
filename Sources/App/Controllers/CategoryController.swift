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
        let param: Int = try req.parameters.next()
        
        let categories = try QueryHelper.categories(request: req)
        let manufacturersCount = try QueryHelper.manufacturerCount(request: req)
        let accessoriesCount = try QueryHelper.accessoriesCount(request: req)
        
        return categories.flatMap(to: View.self, { categories in
            guard let category = categories.first(where: { $0.id == param }) else { throw Abort(.notFound) }
            
            let accessories = try QueryHelper.accessories(request: req, categoryId: category.id).all()
            
            return flatMap(to: View.self, manufacturersCount, accessories, accessoriesCount, { (manufacturersCount, accessories, accessoriesCount) in
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
    }
    
    struct CategoryResponse: Codable {
        let category: Category
        let pageIcon: String
        let accessoryCount: Int
        let manufacturerCount: Int
        let categories: [Category]
        let accessories: [Accessory.AccessoryResponse]
    }
}
