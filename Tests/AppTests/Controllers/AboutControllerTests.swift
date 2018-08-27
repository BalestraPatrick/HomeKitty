//
//  Copyright © 2018 HomeKitty. All rights reserved.
//

import XCTest
@testable import Vapor
@testable import App

class AboutControllerTests: TestCase {

    static var allTests : [(String, (AboutControllerTests) -> () throws -> Void)] {
        return [
            ("testAbout", testAbout),
        ]
    }

    func testAbout() throws {
        let responder = try app.make(Responder.self)
        let wrappedRequest = Request(http: HTTPRequest(url: URL(string: "/about")!), using: app)
        let response = try responder.respond(to: wrappedRequest).wait()

        XCTAssert(response.http.status == .ok)
    }
}
