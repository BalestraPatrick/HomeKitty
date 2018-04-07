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
    let sendGridKey = Environment.get("SENDGRID_API_KEY") ?? "SENDGRID_API_KEY"
    let stripeKey = Environment.get("STRIPE_API_KEY") ?? "STRIPE_API_KEY"

    let dbHostname = Environment.get("DB_HOSTNAME") ?? "localhost"
    let dbUsername = Environment.get("DB_USER") ?? "test"
    let db = Environment.get("DB_DATABASE") ?? "test"
    let dbPort = Environment.get("DB_PORT")?.intValue ?? 5432
    let dbPassword = Environment.get("DB_PASSWORD")

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
