//
//  Copyright © 2018 HomeKitty. All rights reserved.
//

import XCTest
@testable import Vapor
@testable import App

class AboutControllerTests: TestCase {

    func testAbout() throws {
        let responder = try app.make(Responder.self)
        let wrappedRequest = Request(http: HTTPRequest(url: URL(string: "/about")!), using: app)
        let response = try responder.respond(to: wrappedRequest).wait()

        XCTAssert(response.http.status == .ok)
    }
    
}
