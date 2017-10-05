//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import HTTP

final class HomeController {
    
    var droplet: Droplet!
    
    func addRoutes(droplet: Droplet) {
        self.droplet = droplet
        droplet.get(handler: self.home)
        let home = droplet.grouped("home")
        home.get(handler: self.home)
    }
    
    func home(request: Request) throws -> ResponseRepresentable {
        let queryCategory = request.query?["category"]?.string ?? ""
        
        // Get all categories and find out if one of them is selected.
        let categories = try Category.all().select(selected: queryCategory)
        
        let accessories: [Accessory]
        let featuredAccessory: Accessory
        let featuredImage: String
        
        let visibleAccessoriesLimit = 20

        // Get all accessories because no category was selected.
        accessories = try Accessory.makeQuery().filter("approved", true).limit(visibleAccessoriesLimit).all().sorted(by: { $0.date.compare($1.date) == .orderedDescending })

        featuredAccessory = try Accessory.makeQuery().filter("id", 26).first()!

        featuredImage = "/images/featured-item.png"
        
        let nodes = try Node(node: [
            "categories": categories.makeNode(in: nil),
            "accessories": accessories.makeNode(in: nil),
            "featuredImage": featuredImage.makeNode(in: nil),
            "featuredProductLink": featuredAccessory.productLink.makeNode(in: nil),
            "noAccessories": accessories.count == 0
            ])
        return try droplet.view.make("home", nodes)
    }
}

