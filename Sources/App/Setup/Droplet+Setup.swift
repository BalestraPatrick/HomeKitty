//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor

public extension Droplet {

    public func setUp() throws {
        try setUpRoutes()
    }

    /// Configure all routes
    private func setUpRoutes() throws {
        // /home
        let homeController = HomeController()
        homeController.addRoutes(droplet: self)
        
        // /explore
        let exploreController = ExploreController()
        exploreController.addRoutes(droplet: self)

        // /contribute
        let contributeController = ContributeController()
        contributeController.addRoutes(droplet: self)

        // /about
        let aboutController = AboutController()
        aboutController.addRoutes(droplet: self)

        // /manufacturer
        let manufacturerController = ManufacturerController()
        manufacturerController.addRoutes(droplet: self)

        // /donation
        let donationController = DonationController()
        donationController.addRoutes(droplet: self)

    }
}
