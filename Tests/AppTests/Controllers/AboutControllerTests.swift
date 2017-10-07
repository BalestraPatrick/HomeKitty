//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import XCTest
import Testing
@testable import Vapor
@testable import App

class AboutControllerTests: TestCase {

    static var allTests : [(String, (AboutControllerTests) -> () throws -> Void)] {
        return [
            ("testAbout", testAbout),
        ]
    }

    let drop = try! Droplet.testable()

    func testAbout() throws {
        try drop
            .testResponse(to: .get, at: "/aboutddd")
            .assertStatus(is: .ok)
    }
}
