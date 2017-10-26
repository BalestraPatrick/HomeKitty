//
//  FeedControllerTests.swift
//  AppTests
//
//  Created by Moritz Sternemann on 26.10.17.
//

import XCTest
import Testing
@testable import Vapor
@testable import App

class FeedControllerTests: TestCase {
    
    static var allTests : [(String, (FeedControllerTests) -> () throws -> Void)] {
        return [
            ("testRSS", testRSS),
        ]
    }
    
    let drop = try! Droplet.testable()
    
    func testRSS() throws {
        try drop
            .testResponse(to: .get, at: "/rss.xml")
            .assertStatus(is: .ok)
    }
}

