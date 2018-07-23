//
//  Copyright © 2018 Kim de Vos. All rights reserved.
//

import Vapor
import HTTP
import Leaf

public final class AboutController {
    
    init(router: Router) {
        router.get("about", use: about)
    }
    
    func about(_ req: Request) throws -> Future<View> {
        let leaf = try req.make(LeafRenderer.self)
        // temp bug fix: https://github.com/vapor/template-kit/issues/17
        return leaf.render("about", [String: String]())
    }
}
