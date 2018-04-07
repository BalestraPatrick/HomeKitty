//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import XCTest
@testable import Vapor
@testable import App

class AccessoryControllerTests: TestCase {
    
    static var allTests : [(String, (AccessoryControllerTests) -> () throws -> Void)] {
        return [
            ("testAccessories", testAccessories),
        ]
    }
    
    func testAccessories() throws {
        let responder = try app.make(Responder.self)
        let wrappedRequest = Request(http: HTTPRequest(url: URL(string: "/accessories")!), using: app)
        let response = try responder.respond(to: wrappedRequest).wait()

        XCTAssert(response.http.status == .ok)
    }
}
