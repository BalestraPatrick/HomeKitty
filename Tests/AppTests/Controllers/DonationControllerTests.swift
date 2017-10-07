//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import XCTest
import Testing
@testable import Vapor
@testable import App

class DonationControllerTests: TestCase {

    static var allTests : [(String, (DonationControllerTests) -> () throws -> Void)] {
        return [
            ("testDonation", testDonation),
        ]
    }

    let drop = try! Droplet.testable()

    func testDonation() throws {
        try drop
            .testResponse(to: .get, at: "/donation")
            .assertStatus(is: .ok)
    }
}
