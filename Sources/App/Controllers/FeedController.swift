//
//  FeedController.swift
//  App
//
//  Created by Moritz Sternemann on 25.10.17.
//

import Vapor
import Foundation

final class FeedController {
    
    var droplet: Droplet!
    
    func addRoutes(droplet: Droplet) {
        self.droplet = droplet
        droplet.get("/rss.xml", handler: self.rss)
    }
    
    func rss(request: Request) throws -> ResponseRepresentable {
        // Limit of fetched items for accessories query
        let visibleAccessoriesLimit = 18
        
        // Get limited amount of accessories sorted by date
        let accessories = try Accessory.makeQuery().filter("approved", true).sort("date", .descending).limit(visibleAccessoriesLimit).all()
        
        let rssGenerator = RSSFeedGenerator(app: droplet, path: request.uri.path)
        
        return Response(status: .ok, headers: [.contentType: "text/xml;charset=UTF-8"], body: try rssGenerator.accessoriesFeed(accessories))
    }
}
