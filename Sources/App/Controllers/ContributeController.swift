//
//  Copyright © 2018 HomeKitty. All rights reserved.
//

import Vapor
import HTTP
import Leaf
import FluentPostgreSQL

final class ContributeController {
    
    init(router: Router) {
        router.get("contribute", use: contribute)
    }

    func contribute(_ req: Request) throws -> Future<View> {
        let leaf = try req.view()
        return leaf.render("contribute")
    }
}
