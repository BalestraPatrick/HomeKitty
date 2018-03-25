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
        let categories = try Category.query(on: req).sort(\Category.name, .ascending).all()
        let manufacturerCount = try Manufacturer.query(on: req).filter(\Manufacturer.approved == true).count()
        let accessories = try Accessory.query(on: req).filter(\Accessory.approved == true).all()
        
        return flatMap(to: View.self, categories, manufacturerCount, accessories) { categories, manufacturersCount, accesories in
            return try categories.map { try $0.makeResponse(req) }.flatMap(to: View.self, on: req, { categories in
                return accessories.flatMap(to: View.self, { accessories in
                    return try accessories.map { try $0.makeResponse(req) }.flatMap(to: View.self, on: req, { accesories in
                        let data = AccessoriesResponse(accessories: accesories,
                                                       categories: categories,
                                                       accessoryCount: accesories.count,
                                                       manufacturerCount: manufacturersCount)
                        let leaf = try req.make(LeafRenderer.self)
                        return leaf.render("accessories", data)
                    })
                })
            })
        }
    }
    
    func accessory(_ req: Request) throws -> Future<View> {
        let paramId: Int = try req.parameter()
        
        let accessory = try Accessory.query(on: req).filter(\Accessory.id == paramId).first()
        let categories = try Category.query(on: req).sort(\Category.name, .ascending).all()
        let manufacturersCount = try Manufacturer.query(on: req).filter(\Manufacturer.approved == true).count()
        let accessoryCount = try Accessory.query(on: req).filter(\Accessory.approved == true).count()
        
        return accessory.flatMap(to: View.self) { accessory in
            guard let accessory = accessory else { throw Abort(.notFound) }
            
            return try accessory.makeResponse(req).flatMap(to: View.self, { accessoryItem in
                return flatMap(to: View.self, categories, manufacturersCount, accessoryCount) { (categories, manufacturersCount, accessoryCount) in
                    return try categories.map { try $0.makeResponse(req) }.flatMap(to: View.self, on: req, { categoryItems in
                        
                        let data = AccessoryResponse(pageIcon: categories.first(where: { $0.id == accessory.categoryId })?.image ?? "",
                                                     accessory: accessoryItem,
                                                     categories: categoryItems,
                                                     accessoryCount: accessoryCount,
                                                     manufacturerCount: manufacturersCount)
                        
                        let leaf = try req.make(LeafRenderer.self)
                        return leaf.render("accessory", data)
                    })
                }
            })
        }
    }
    
    private struct AccessoryResponse: Codable {
        let pageTitle = "Accessory Details"
        let pageIcon: String
        let accessory: Accessory.AccessoryResponse
        let categories: [Category.CategoryResponse]
        let accessoryCount: Int
        let manufacturerCount: Int
    }
    
    private struct AccessoriesResponse: Codable {
        let accessories: [Accessory.AccessoryResponse]
        let categories: [Category.CategoryResponse]
        let accessoryCount: Int
        let manufacturerCount: Int
    }
}
