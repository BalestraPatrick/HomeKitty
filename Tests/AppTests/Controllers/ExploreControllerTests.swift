//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import XCTest
import Testing
@testable import Vapor
@testable import App

class ExploreControllerTests: TestCase {

    static var allTests : [(String, (ExploreControllerTests) -> () throws -> Void)] {
        return [
            ("testExplore", testExplore),
        ]
    }

    let drop = try! Droplet.testable()

    func testExplore() throws {
        try drop
            .testResponse(to: .get, at: "/explore")
            .assertStatus(is: .ok)
    }
}
