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
        // Get all categories to display in sidebar
        let categories = try Category.all()
        
        let accessories: [Accessory]
        var accessoriesDateString: [String]
        let featuredAccessoryImage: String
        let featuredAccessoryLink: String
        
        // Limit of fetched items for accessories query
        let visibleAccessoriesLimit = 18

        // Get limited amout of accessories sorted by date
        accessories = try Accessory.makeQuery().filter("approved", true).sort("date", .descending).limit(visibleAccessoriesLimit).all()

        // Creates a time ago string from the date of each accessory and stores it in a new array
        accessoriesDateString = accessories.map { $0.date.timeAgoString() }

        // Path to the banner image of the featured image
        featuredAccessoryImage = "/images/featured.jpg"

        featuredAccessoryLink = "https://www.xxter.com/pairot/homekitty"

        // Creates a time ago string from the date of each accessory and stores it in a new array
        accessoriesDateString = accessories.map { $0.date.timeAgoString() }

        let accessoryCount = try Accessory.makeQuery().filter("approved", true).count()
        let manufacturerCount = try Manufacturer.makeQuery().filter("approved", true).count()

        let nodes = try Node(node: [
            "categories": categories.makeNode(in: nil),
            "accessories": accessories.makeNode(in: nil),
            "featuredImage": featuredAccessoryImage.makeNode(in: nil),
            "featuredAccessory": featuredAccessoryLink,
            "accessoriesDateString": accessoriesDateString.makeNode(in: nil),
            "noAccessories": accessories.count == 0,
            "accessoryCount": accessoryCount.makeNode(in: nil),
            "manufacturerCount": manufacturerCount.makeNode(in: nil),
        ])
        return try droplet.view.make("home", nodes)
    }
}

