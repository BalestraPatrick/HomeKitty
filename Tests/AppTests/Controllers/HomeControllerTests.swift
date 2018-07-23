//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import XCTest
@testable import Vapor
@testable import App

class HomeControllerTests: TestCase {
    
    static var allTests : [(String, (HomeControllerTests) -> () throws -> Void)] {
        return [
            ("testHome", testHome),
        ]
    }

    func testHome() throws {
        let responder = try app.make(Responder.self)
        let wrappedRequest = Request(http: HTTPRequest(), using: app)
        let response = try responder.respond(to: wrappedRequest).wait()

        XCTAssert(response.http.status == .ok)
    }
}
