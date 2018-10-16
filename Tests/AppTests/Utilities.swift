@testable import App
@testable import Vapor

import XCTest
import FluentPostgreSQL

//sourcery: disableTests
class TestCase: XCTestCase {

    lazy var app: Application = {
        var config = Config.default()
        var env = try! Environment.detect()
        var services = Services.default()

        try! App.configure(&config, env: &env, services: &services)

        return try! Application(config: config,
                                environment: env,
                                services: services)
    }()
}
