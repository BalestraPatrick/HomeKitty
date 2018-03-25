//
//  Copyright © 2018 Kim de Vos. All rights reserved.
//

import Vapor
import HTTP
import Leaf
import FluentPostgreSQL

final class ContributeController {
    
    init(router: Router) {
        router.get("contribute", use: contribute)
        router.post("contribute", use: submit)
        //        group.get(handler: contribute)
        //        group.post("submit", handler: submit)
    }
    
    func contribute(_ req: Request) throws -> Future<View> {
        let manufacturers = try Manufacturer.query(on: req).filter(\Manufacturer.approved == true).sort(\Manufacturer.name, .ascending).all()
        let categories = try Category.query(on: req).sort(\Category.name, .ascending).all()
        let bridges = try Category.query(on: req).filter(\Category.name == "Bridges").first().flatMap(to: [Accessory].self, { (category)  in
            guard let category = category else { throw Abort(.internalServerError) }
            
            return try category.accessories.query(on: req).all()
        })
        
        let regions = try Region.query(on: req).sort(\Region.fullName, .ascending).all()
        
        return flatMap(to: View.self, manufacturers, categories, bridges, regions, { (manufacturers, categories, bridges, regions) in
            return try categories.map { try $0.makeResponse(req) }.flatMap(to: View.self, on: req, { categories in
                return try bridges.map { try $0.makeResponse(req) }.flatMap(to: View.self, on: req, { bridges in
                    let data = ContributeResponse(categories: categories,
                                                  manufacturers: manufacturers,
                                                  bridges: bridges,
                                                  regions: regions)
                    
                    let leaf = try req.make(LeafRenderer.self)
                    return leaf.render("contribute", data)
                })
            })
        })
    }
    
    func submit(_ req: Request) throws -> Future<View> {
        //        var manufacturerId: Identifier?
        //        if let name = request.formURLEncoded?["manufacturer-name"]?.string,
        //            let website = request.formURLEncoded?["manufacturer-website"]?.string {
        //            // Create the manufacturer because it's a new one
        //            let manufacturer = Manufacturer(name: name, websiteLink: website)
        //            try manufacturer.save()
        //            manufacturerId = manufacturer.id
        //        } else if let manufacturerName = request.formURLEncoded?["manufacturer"]?.string, let category = try Manufacturer.makeQuery().filter("name", manufacturerName).first() {
        //            // Grab the exising manufacturer and store it for later assignment to the accessory.
        //            manufacturerId = category.id
        //        } else {
        //            return "Unrecognized manufacturer or error in creating it."
        //        }
        //
        //        if let name = request.formURLEncoded?["name"]?.string,
        //            let price = request.formURLEncoded?["price"]?.string,
        //            let image = request.formURLEncoded?["image"]?.string,
        //            let link = request.formURLEncoded?["link"]?.string,
        //            let categoryName = request.formURLEncoded?["category"]?.string,
        //            let manufacturerId = manufacturerId {
        //                let released = request.formURLEncoded?["released"]?.bool ?? false
        //                let requiresHub = request.formURLEncoded?["requires_hub"]?.bool ?? false
        //                let requiredBridgeName = request.formURLEncoded?["required_bridge"]?.string
        //                let bridge = try Accessory.makeQuery().filter("name", requiredBridgeName).first()
        //                if let category = try Category.makeQuery().filter("name", categoryName).first() {
        //                    let accessory = Accessory(
        //                        name: name,
        //                        image: image,
        //                        price: price.normalizedPrice,
        //                        productLink: link,
        //                        amazonLink: nil,
        //                        categoryId: category.id!,
        //                        manufacturerId: manufacturerId,
        //                        released: released,
        //                        requiresHub: requiresHub,
        //                        requiredHubId: bridge?.id
        //                    )
        //
        //                    try accessory.save()
        //
        //                    if let regions = request.formURLEncoded?["regions"]?.array {
        //                        let regionsFullNames = regions.map { $0.string }
        //                        for regionFullName in regionsFullNames {
        //                            if let region = try Region.makeQuery().filter("full_name", regionFullName).first() {
        //                                try accessory.regions.add(region)
        //                            }
        //                        }
        //                    }
        //                }
        //        }
        //        let node = try Node(node: ["success": true])
        //        return try droplet.view.make("contribute", node)
        
        let leaf = try req.make(LeafRenderer.self)
        return leaf.render("contribute", ["success": true])
    }
    
    struct ContributeResponse: Codable {
        let categories: [Category.CategoryResponse]
        let manufacturers: [Manufacturer]
        let bridges: [Accessory.AccessoryResponse]
        let regions: [Region]
    }
}
