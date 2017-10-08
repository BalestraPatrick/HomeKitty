//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import XCTest
import Testing
@testable import Vapor
@testable import App

class ReportControllerTests: TestCase {
    
    static var allTests : [(String, (ReportControllerTests) -> () throws -> Void)] {
        return [
            ("testReport", testReport),
        ]
    }
    
    let drop = try! Droplet.testable()
    
    func testReport() throws {
        try drop
            .testResponse(to: .get, at: "/report")
            .assertStatus(is: .ok)
    }
}
