//
//  Copyright © 2017 Kim de Vos. All rights reserved.
//
import Routing
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Configuring controllers
    _ = AboutController(router: router)
    _ = ManufacturerController(router: router)
    _ = AccessoryController(router: router)
    _ = SearchController(router: router)
    _ = ReportController(router: router)
    _ = DonationController(router: router)
    _ = CategoryController(router: router)
    _ = HomeController(router: router)
    _ = ContributeController(router: router)
}
