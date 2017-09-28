//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import HTTP

public final class AboutController {

    var droplet: Droplet!

    func addRoutes(droplet: Droplet) {
        self.droplet = droplet
        droplet.get("about", handler: about)
    }

    func about(request: Request) throws -> ResponseRepresentable {
        return try droplet.view.make("about")
    }
}
