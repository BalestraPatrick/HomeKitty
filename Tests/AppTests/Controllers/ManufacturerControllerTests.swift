//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import XCTest
@testable import Vapor
@testable import App

class ManufacturerControllerTests: TestCase {

    static var allTests : [(String, (ManufacturerControllerTests) -> () throws -> Void)] {
        return [
            ("testManufacturers", testManufacturers),
        ]
    }

    func testManufacturers() throws {
        let responder = try app.make(Responder.self)
        let wrappedRequest = Request(http: HTTPRequest(url: URL(string: "/manufacturers")!), using: app)
        let response = try responder.respond(to: wrappedRequest).wait()

        XCTAssert(response.http.status == .ok)
    }
}
