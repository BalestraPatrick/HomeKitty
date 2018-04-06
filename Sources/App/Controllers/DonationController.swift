//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import HTTP
import Stripe
import Leaf

final class DonationController {
    
    init(router: Router) {
        router.get("donation", "thanks" , use: thanks)
        router.get("donation", use: donation)
    }
    
    
    func donation(_ req: Request) throws -> Future<StripeCharge> {
        guard let token: String = try req.query.get(at: "token"),
            let amount: Int = try req.query.get(at: "amount") else {
                throw Abort(.badRequest)
        }
        
        let stripeClient = try req.make(StripeClient.self)
        
        return try stripeClient.charge.create(amount: amount,
                                              currency: .usd,
                                              capture: true,
                                              description: "HomeKitty Donation",
                                              source: token,
                                              statementDescriptor: "HomeKitty Donation")
    }
    
    func thanks(_ req: Request) throws -> Future<View> {
        let leaf = try req.make(LeafRenderer.self)
        return leaf.render("thanks")
    }
}
