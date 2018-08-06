//
//  Copyright © HomeKitty. All rights reserved.
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
        router.get("accessory", use: oldAccessory)
    }
    
    func accessories(_ req: Request) throws -> Future<View> {
        let categories = try QueryHelper.categories(request: req)
        let manufacturerCount = try QueryHelper.manufacturerCount(request: req)
        let accessories = try QueryHelper.accessories(request: req).all()

        return flatMap(to: View.self, categories, manufacturerCount, accessories) { categories, manufacturersCount, accessories in
            let data = AccessoriesResponse(noAccessoriesFound: accessories.isEmpty,
                accessories: accessories.map { Accessory.AccessoryResponse(accessory: $0.0, manufacturer: $0.1) },
                                           categories: categories,
                                           accessoryCount: accessories.count,
                                           manufacturerCount: manufacturersCount, accessoriesSelected: true)
            let leaf = try req.view()
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
                let data = AccessoryResponse(pageIcon: categories.first(where: { $0.id == accessory.0.categoryId })?.image ?? "",
                                             accessory: Accessory.AccessoryResponse(accessory: accessory.0, manufacturer: accessory.1),
                                             categories: categories,
                                             accessoryCount: accessoryCount,
                                             manufacturerCount: manufacturersCount)

                let leaf = try req.view()
                return leaf.render("accessory", data)
            }
        }
    }

    func oldAccessory(_ req: Request) throws -> Future<Response> {
        let paramName: String = try req.query.get(at: "name")

        return Accessory.query(on: req).filter(\Accessory.name == paramName).first().map { accessory in
            return req.redirect(to: "accessories/\(accessory?.id ?? -1)")
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
        let noAccessoriesFound: Bool
        let accessories: [Accessory.AccessoryResponse]
        let categories: [Category]
        let accessoryCount: Int
        let manufacturerCount: Int
        let accessoriesSelected: Bool
    }
}
