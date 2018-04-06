//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import FluentPostgreSQL
import Leaf
//import LeafErrorMiddleware
import Stripe
import SendGrid

public func configure(_ config: inout Config, env: inout Environment, services: inout Services) throws {
    guard let sendGridKey = ProcessInfo.processInfo.environment["SENDGRID_API_KEY"]?.stringValue,
        let stripeKey = ProcessInfo.processInfo.environment["STRIPE_API_KEY"]?.stringValue,
        let dbHostname = ProcessInfo.processInfo.environment["DB_HOSTNAME"]?.stringValue,
        let dbUsername = ProcessInfo.processInfo.environment["DB_USER"]?.stringValue,
        let db = ProcessInfo.processInfo.environment["DB_DATABASE"]?.stringValue else {
            fatalError("Missing some API keys")
    }

    let dbPort = ProcessInfo.processInfo.environment["DB_PORT"]?.intValue ?? 5432
    let dbPassword = ProcessInfo.processInfo.environment["DB_PASSWORD"]?.stringValue

    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(LeafProvider())

    // Stripe
    let config = SendGridConfig(apiKey: sendGridKey)

    services.register(config)

    try services.register(SendGridProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig()
    middlewares.use(DateMiddleware.self)
    middlewares.use(ErrorMiddleware.self)
    middlewares.use(FileMiddleware.self)
    services.register(middlewares)

    // Configure a SQLite database

    let databases = PostgreSQLDatabase(config: PostgreSQLDatabaseConfig(hostname: dbHostname, port: dbPort, username: dbUsername, database: db, password: dbPassword))
    databases.enableLogging(using: DatabaseLogger.print)
    
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: Manufacturer.self, database: .psql)
    migrations.add(model: Accessory.self, database: .psql)
    migrations.add(model: Region.self, database: .psql)
    migrations.add(model: AccessoryRegionPivot.self, database: .psql)

    services.register(migrations)

    // Configure the rest of your application here
}
