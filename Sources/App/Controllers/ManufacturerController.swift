//
//  Copyright © 2018 HomeKitty. All rights reserved.
//

import Vapor
import HTTP
import FluentPostgreSQL
import Leaf

final class ManufacturerController {
    
    init(router: Router) {
        router.get("manufacturers", use: manufacturers)
        router.get("manufacturers", Int.parameter, use: manufacturer)
        router.get("manufacturer", use: oldManufacturer)
    }
    
    func manufacturer(_ req: Request) throws -> Future<View> {
        let param: Int = try req.parameters.next()
        
        let manufacturer = try QueryHelper.manufacturer(request: req, id: param)
        let categories = try QueryHelper.categories(request: req)
        let manufacturersCount = try QueryHelper.manufacturerCount(request: req)
        let accessories = try QueryHelper.accessories(request: req, manufacturerId: param).all()
        
        return manufacturer.flatMap(to: View.self) { manufacturer in
            guard let manufacturer = manufacturer else { throw Abort(.notFound) }
            
            return flatMap(to: View.self, categories, manufacturersCount, accessories, { (categories, manufacturersCount, accessories) in
                let leaf = try req.view()
                let responseData = ManufacturerResponse(manufacturer: manufacturer,
                                                        pageIcon: "",
                                                        accessoryCount: accessories.count,
                                                        manufacturerCount: manufacturersCount,
                                                        categories: categories,
                                                        accessories: accessories.map { Accessory.AccessoryResponse(accessory: $0.0, manufacturer: $0.1) })
                
                return leaf.render("manufacturer", responseData)
            })
        }
    }
    
    func manufacturers(_ req: Request) throws -> Future<View> {
        let manufacturers = try QueryHelper.manufacturers(request: req)
        let categories = try QueryHelper.categories(request: req)
        let accessoryCount = try QueryHelper.accessoriesCount(request: req)
        
        return flatMap(to: View.self, manufacturers, categories, accessoryCount, { (manufacturers, categories, accessoryCount) in
            let leaf = try req.view()
            let responseData = ManufacturersResponse(pageTitle: "All Manufacturers",
                                                     pageIcon: "",
                                                     accessoryCount: accessoryCount,
                                                     manufacturerCount: manufacturers.count,
                                                     categories: categories,
                                                     manufacturers: manufacturers,
                                                     manufacturersSelected: true)
            return leaf.render("manufacturers", responseData)
        })
    }

    func oldManufacturer(_ req: Request) throws -> Future<Response> {
        let paramName: String = try req.query.get(at: "name")

        return Manufacturer.query(on: req).filter(\Manufacturer.name == paramName).first().map { manufacturer in
            return req.redirect(to: "manufacturers/\(manufacturer?.id ?? -1)")
        }
    }
    
    struct ManufacturersResponse: Codable {
        let pageTitle: String
        let pageIcon: String
        let accessoryCount: Int
        let manufacturerCount: Int
        let categories: [Category]
        let manufacturers: [Manufacturer]
        let manufacturersSelected: Bool
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
