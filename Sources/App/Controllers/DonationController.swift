//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import HTTP
import Stripe

final class DonationController {

    var droplet: Droplet!

    func addRoutes(droplet: Droplet) {
        self.droplet = droplet
        let group = droplet.grouped("donation")
        group.post(handler: donation)
        group.get("thanks", handler: thanks)
    }

    func donation(request: Request) throws -> ResponseRepresentable {
        guard let token: String = try request.formURLEncoded?.get("token"), let amount: String = try request.formURLEncoded?.get("amount") else {
            throw Abort.badRequest
        }
        let charge = try droplet.stripe?.charge.create(
            amount: Int(amount)! * 100,
            in: .usd,
            withFee: nil,
            toAccount: nil,
            capture: true,
            description: "HomeKitty Donation",
            destinationAccountId: nil,
            destinationAmount: nil,
            transferGroup: nil,
            onBehalfOf: nil,
            receiptEmail: nil,
            shippingLabel: nil,
            customer: nil,
            statementDescriptor: "HomeKitty Donation",
            source: token
        )
        return try charge?.json() ?? JSON([:])
    }

    func thanks(request: Request) throws -> ResponseRepresentable {
        return try droplet.view.make("thanks")
    }
}
