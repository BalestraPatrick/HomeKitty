//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import XCTest
import Testing
@testable import Vapor
@testable import App

class HomeControllerTests: TestCase {
    
    static var allTests : [(String, (HomeControllerTests) -> () throws -> Void)] {
        return [
            ("testHome", testHome),
        ]
    }
    
    let drop = try! Droplet.testable()
    
    func testHome() throws {
        try drop
            .testResponse(to: .get, at: "/")
            .assertStatus(is: .ok)
    }
}

