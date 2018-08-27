//
//  Copyright © 2018 HomeKitty. All rights reserved.
//

import XCTest
@testable import Vapor
@testable import App

class ReportControllerTests: TestCase {
    
    static var allTests : [(String, (ReportControllerTests) -> () throws -> Void)] {
        return [
            ("testReport", testReport),
        ]
    }

    func testReport() throws {
        let responder = try app.make(Responder.self)
        let wrappedRequest = Request(http: HTTPRequest(url: URL(string: "/report")!), using: app)
        let response = try responder.respond(to: wrappedRequest).wait()

        XCTAssert(response.http.status == .ok)
    }
}
