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
        let visibleAccessoriesLimit = 18

        // Fetch featured accessory
        let featuredAccessory = try QueryHelper.featuredAccessories(request: req).all()
        let categories = try QueryHelper.categories(request: req)
        let manufacturersCount = try QueryHelper.manufacturerCount(request: req)
        let accessoryCount = try QueryHelper.accessoriesCount(request: req)
        let accessories = try QueryHelper.accessories(request: req)
            .range(lower: 0, upper: visibleAccessoriesLimit)
            .all()

        return flatMap(to: View.self, featuredAccessory, categories, manufacturersCount, accessoryCount, accessories, { (featuredAccessory, categories, manufacturersCount, accessoryCount, accessories) in
            let data = HomeResponse(featuredAccessory: featuredAccessory.first.map { Accessory.AccessoryResponse(accessory: $0.0, manufacturer: $0.1) },
                                    categories: categories,
                                    accessories: accessories.map { Accessory.AccessoryResponse(accessory: $0.0, manufacturer: $0.1) },
                                    accessoryCount: accessoryCount,
                                    manufacturerCount: manufacturersCount)
            let leaf = try req.make(LeafRenderer.self)
            return leaf.render("home", data)
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
