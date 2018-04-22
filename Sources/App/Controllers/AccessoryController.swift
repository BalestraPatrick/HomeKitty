//
//  Copyright © 2018 Kim de Vos. All rights reserved.
//

import Foundation
import Vapor
import HTTP
import FluentPostgreSQL
import Leaf
import Fluent

final class AccessoryController {
    
    init(router: Router) {
        router.get("accessories", Int.parameter, use: accessory)
        router.get("accessories", use: accessories)
    }
    
    func accessories(_ req: Request) throws -> Future<View> {
        let categories = try QueryHelper.categories(request: req)
        let manufacturerCount = try QueryHelper.manufacturerCount(request: req)
        let accessories = try QueryHelper.accessories(request: req).all()
        
        return flatMap(to: View.self, categories, manufacturerCount, accessories) { categories, manufacturersCount, accesories in
            let data = AccessoriesResponse(accessories: accesories,
                                           categories: categories,
                                           accessoryCount: accesories.count,
                                           manufacturerCount: manufacturersCount)
            let leaf = try req.make(LeafRenderer.self)
            return leaf.render("accessories", data)
        }
    }
    
    func accessory(_ req: Request) throws -> Future<View> {
        let paramId: Int = try req.parameters.next()
        
        let accessory = try QueryHelper.accessory(request: req, id: paramId)
        let categories = try QueryHelper.categories(request: req)
        let manufacturersCount = try QueryHelper.manufacturerCount(request: req)
        let accessoryCount = try QueryHelper.accessoriesCount(request: req)
        
        return accessory.flatMap(to: View.self) { accessory in
            guard let accessory = accessory else { throw Abort(.notFound) }
            
            return flatMap(to: View.self, categories, manufacturersCount, accessoryCount) { (categories, manufacturersCount, accessoryCount) in
                let data = AccessoryResponse(pageIcon: categories.first(where: { $0.id == accessory.categoryId })?.image ?? "",
                                             accessory: accessory,
                                             categories: categories,
                                             accessoryCount: accessoryCount,
                                             manufacturerCount: manufacturersCount)

                let leaf = try req.make(LeafRenderer.self)
                return leaf.render("accessory", data)
            }
        }
    }
    
    private struct AccessoryResponse: Codable {
        let pageTitle = "Accessory Details"
        let pageIcon: String
        let accessory: Accessory.AccessoryResponse
        let categories: [Category]
        let accessoryCount: Int
        let manufacturerCount: Int
    }
    
    private struct AccessoriesResponse: Codable {
        let accessories: [Accessory.AccessoryResponse]
        let categories: [Category]
        let accessoryCount: Int
        let manufacturerCount: Int
    }
}
