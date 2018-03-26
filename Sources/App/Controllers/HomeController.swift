//
//  Copyright © 2018 Kim de Vos. All rights reserved.
//

import Vapor
import HTTP
import Leaf
import FluentPostgreSQL

final class HomeController {

    init(router: Router) {
        router.get(use: home)
    }

    func home(_ req: Request) throws -> Future<View> {

        // Path to the banner image of the featured image
        let featuredAccessoryImage = "/images/featured-item.png"
        let visibleAccessoriesLimit = 18

        // Fetch featured accessory
        let featuredAccessory = try Accessory.query(on: req).filter(\Accessory.featured == true).sort(\Accessory.date, .descending).all()
        let categories = try Category.query(on: req).sort(\Category.name, .ascending).all()
        let manufacturersCount = try Manufacturer.query(on: req).filter(\Manufacturer.approved == true).count()
        let accessoryCount = try Accessory.query(on: req).filter(\Accessory.approved == true).count()
        let accessories = try Accessory.query(on: req).filter(\Accessory.approved == true).sort(\Accessory.date, .descending).range(lower: 0, upper: visibleAccessoriesLimit).all()

        return flatMap(to: View.self, featuredAccessory, categories, manufacturersCount, accessoryCount, accessories, { (featuredAccessory, categories, manufacturersCount, accessoryCount, accessories) in
                return try featuredAccessory.map { try $0.makeResponse(req) }.flatMap(to: View.self, on: req, { featuredAccessory in
                    return try accessories.map { try $0.makeResponse(req) }.flatMap(to: View.self, on: req, { accessories in
                        let data = HomeResponse(featuredAccessory: featuredAccessory.first,
                                                categories: categories,
                                                accessories: accessories,
                                                accessoryCount: accessoryCount,
                                                manufacturerCount: manufacturersCount)
                        let leaf = try req.make(LeafRenderer.self)
                        return leaf.render("home", data)
                })
            })
        })
    }

    private struct HomeResponse: Codable {
        let featuredAccessory: Accessory.AccessoryResponse?
        let categories: [Category]
        let accessories: [Accessory.AccessoryResponse]
        let accessoryCount: Int
        let manufacturerCount: Int
    }
}
