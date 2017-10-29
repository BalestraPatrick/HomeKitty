//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import XCTest
import Testing
@testable import Vapor
@testable import App

class AccessoryControllerTests: TestCase {
    
    static var allTests : [(String, (AccessoryControllerTests) -> () throws -> Void)] {
        return [
            ("testAccessory", testAccessory),
        ]
    }
    
    let drop = try! Droplet.testable()
    
    func testAccessory() throws {
        try drop
            .testResponse(to: .get, at: "/accessory")
            .assertStatus(is: .notFound)
    }
}
