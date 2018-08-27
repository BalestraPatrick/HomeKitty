//
//  RSSController.swift
//  App
//
//  Created by Patrick Balestra on 8/26/18.
//

import Vapor
import HTTP

final class RSSController {

    lazy var rssGenerator = RSSFeedGenerator()

    init(router: Router) {
        router.get("rss.xml", use: rss)
    }

    func rss(_ req: Request) throws -> Future<String> {
        let items = try QueryHelper.accessories(request: req).all()
        return items.flatMap { items in
            let accessories = items.map { $0.0 }
            let manufacturers = items.map { $0.1 }
            return try self.rssGenerator.generateFeed(req, accessories: accessories, manufacturers: manufacturers)
        }
    }
}
