//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import XCTest
import Testing
@testable import Vapor
@testable import App

class ManufacturerControllerTests: TestCase {

    static var allTests : [(String, (ManufacturerControllerTests) -> () throws -> Void)] {
        return [
            ("testManufacturer", testManufacturer),
        ]
    }

    let drop = try! Droplet.testable()

    func testManufacturer() throws {
        try drop
            .testResponse(to: .get, at: "/manufacturer")
            .assertStatus(is: .ok)
    }
}
