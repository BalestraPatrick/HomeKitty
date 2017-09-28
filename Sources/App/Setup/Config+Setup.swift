//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import PostgreSQLProvider
import LeafProvider
import LeafErrorMiddleware
import Stripe

public extension Config {

    public func setUp() throws {
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setUpProviders()
        try setUpMiddlewares()
        try setUpPreparations()
    }

    private func setUpProviders() throws {
        try addProvider(Stripe.Provider.self)
        try addProvider(PostgreSQLProvider.Provider.self)
        try addProvider(LeafProvider.Provider.self)
    }

    private func setUpMiddlewares() throws {
        addConfigurable(middleware: LeafErrorMiddleware.init, name: "leaf-error")
//        addConfigurable(middleware: Bugsnag.Middleware.init, name: "bugsnag")
    }

    private func setUpPreparations() throws {
        preparations.append(Manufacturer.self)
        preparations.append(Category.self)
        preparations.append(Accessory.self)
    }
}
