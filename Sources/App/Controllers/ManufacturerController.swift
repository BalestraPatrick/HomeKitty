//
//  Copyright © 2018 Kim de Vos. All rights reserved.
//

import Vapor
import HTTP
import FluentPostgreSQL
import Leaf

final class ManufacturerController {
    
    init(router: Router) {
        router.get("manufacturers", use: manufacturers)
        router.get("manufacturers", Int.parameter, use: manufacturer)
    }
    
    func manufacturer(_ req: Request) throws -> Future<View> {
        let param: Int = try req.parameter()
        
        let manufacturer = try QueryHelper.manufacturer(request: req, id: param)
        let categories = try QueryHelper.categories(request: req)
        let manufacturersCount = try QueryHelper.manufacturerCount(request: req)
        let accessories = try QueryHelper.accessories(request: req, manufacturerId: param).all()
        
        return manufacturer.flatMap(to: View.self) { manufacturer in
            guard let manufacturer = manufacturer else { throw Abort(.notFound) }
            
            return flatMap(to: View.self, categories, manufacturersCount, accessories, { (categories, manufacturersCount, accessories) in
                let leaf = try req.make(LeafRenderer.self)
                let responseData = ManufacturerResponse(manufacturer: manufacturer,
                                                        pageIcon: "",
                                                        accessoryCount: accessories.count,
                                                        manufacturerCount: manufacturersCount,
                                                        categories: categories,
                                                        accessories: accessories)
                
                return leaf.render("manufacturer", responseData)
            })
        }
    }
    
    func manufacturers(_ req: Request) throws -> Future<View> {
        let manufacturers = try QueryHelper.manufacturers(request: req)
        let categories = try QueryHelper.categories(request: req)
        let accessoryCount = try QueryHelper.accessoriesCount(request: req)
        
        return flatMap(to: View.self, manufacturers, categories, accessoryCount, { (manufacturers, categories, accessoryCount) in
            let leaf = try req.make(LeafRenderer.self)
            let responseData = ManufacturersResponse(pageTitle: "All Manufacturers",
                                                     pageIcon: "",
                                                     accessoryCount: accessoryCount,
                                                     manufacturerCount: manufacturers.count,
                                                     categories: categories,
                                                     manufacturers: manufacturers)
            
            return leaf.render("manufacturers", responseData)
        })
    }
    
    struct ManufacturersResponse: Codable {
        let pageTitle: String
        let pageIcon: String
        let accessoryCount: Int
        let manufacturerCount: Int
        let categories: [Category]
        let manufacturers: [Manufacturer]
    }
    
    struct ManufacturerResponse: Codable {
        let manufacturer: Manufacturer
        let pageIcon: String
        let accessoryCount: Int
        let manufacturerCount: Int
        let categories: [Category]
        let accessories: [Accessory.AccessoryResponse]
    }
}
