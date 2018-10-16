//
//  Copyright © 2018 HomeKitty. All rights reserved.
//

import XCTest
@testable import Vapor
@testable import App

class DonationControllerTests: TestCase {

    func testDonationThanks() throws {
        let responder = try app.make(Responder.self)
        let wrappedRequest = Request(http: HTTPRequest(url: URL(string: "/donation/thanks")!), using: app)
        let response = try responder.respond(to: wrappedRequest).wait()

        XCTAssert(response.http.status == .ok)
    }
    
}
