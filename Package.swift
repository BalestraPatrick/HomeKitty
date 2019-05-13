// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "HomeKitty",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.3.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "3.2.0"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.2"),
        .package(url: "https://github.com/vapor-community/stripe-provider.git", from: "2.3.2"),
        .package(url: "https://github.com/brokenhandsio/leaf-error-middleware.git", from: "1.1.0"),
        .package(url: "https://github.com/vapor-community/sendgrid-provider.git", from: "3.0.6"),
        .package(url: "https://github.com/vapor/database-kit.git", from: "1.3.3"),
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
