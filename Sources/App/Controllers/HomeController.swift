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

        // Fetch featured accessory
        let featuredAccessories = try QueryHelper.featuredAccessories(request: req).all()
        let categories = try QueryHelper.categories(request: req)
        let manufacturersCount = try QueryHelper.manufacturerCount(request: req)
        let accessoryCount = try QueryHelper.accessoriesCount(request: req)
        let visibleAccessoriesLimit = 18
        let accessories = try QueryHelper.accessories(request: req)
            .range(lower: 0, upper: visibleAccessoriesLimit)
            .all()

        return flatMap(to: View.self, featuredAccessories, categories, manufacturersCount, accessoryCount, accessories, { featuredAccessories, categories, manufacturersCount, accessoryCount, accessories in
            let featuredAccessory = featuredAccessories.first.map { Accessory.FeaturedResponse(name: $0.0.name, externalLink: "https://www.xxter.com/pairot/homekitty", bannerImage: "/images/featured.jpg") }

            let data = HomeResponse(featuredAccessory: featuredAccessory,
                                    categories: categories,
                                    accessories: accessories.map { Accessory.AccessoryResponse(accessory: $0.0, manufacturer: $0.1) },
                                    accessoryCount: accessoryCount,
                                    manufacturerCount: manufacturersCount)
            let leaf = try req.make(LeafRenderer.self)
            return leaf.render("home", data)
        })
    }

    private struct HomeResponse: Codable {
        let featuredAccessory: Accessory.FeaturedResponse?
        let categories: [Category]
        let accessories: [Accessory.AccessoryResponse]
        let accessoryCount: Int
        let manufacturerCount: Int
    }
}
