// swift-tools-version:4.1

import PackageDescription

let package = Package(
    name: "HomeKitty",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.7"),
        .package(url: "https://github.com/vapor/fluent.git", from: "3.0.0"),

        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor-community/stripe-provider.git", from: "2.0.9"),
        .package(url: "https://github.com/brokenhandsio/leaf-error-middleware.git", .branch("vapor3")),
        .package(url: "https://github.com/vapor-community/sendgrid-provider.git", from: "3.0.4"),
        .package(url: "https://github.com/vapor/database-kit.git", from: "1.3.0"),
    ],
    targets: [
        .target(name: "App",
                dependencies: ["Vapor",
                               "Fluent",
                               "FluentPostgreSQL",
                               "Leaf",
                               "Stripe",
                               "SendGrid",
                               "LeafErrorMiddleware"],
                exclude: ["Config",
                          "Database",
                          "Localization",
                          "Public",
                          "Resources"]
        ),
        .testTarget(name: "AppTests", dependencies: ["App"]),
        .target(name: "Run", dependencies: ["App"])
    ]
)
