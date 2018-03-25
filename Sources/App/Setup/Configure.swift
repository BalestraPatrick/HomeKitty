//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import FluentPostgreSQL
import Leaf
//import LeafErrorMiddleware
import Stripe
//import SendGridProvider

public func configure(_ config: inout Config, env: inout Environment, services: inout Services
    ) throws {


    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(LeafProvider())

    // Stripe
//    let config = StripeConfig(apiKey: "sk_12345678")
//
//    services.register(config)
//
//    StripeProvider()
//
//    try services.register()

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
    let databases = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "kimdevos", database: "postgres")
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: Manufacturer.self, database: .psql)
    migrations.add(model: Accessory.self, database: .psql)
    migrations.add(model: Region.self, database: .psql)
    services.register(migrations)

    // Configure the rest of your application here
}
