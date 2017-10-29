// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "HomeKitty",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor-community/postgresql-provider.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/fluent-provider.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/leaf-provider.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/node.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor-community/stripe.git", from: "1.0.0"),
        .package(url: "https://github.com/brokenhandsio/leaf-error-middleware.git", from: "0.1.0"),
        .package(url: "https://github.com/vapor-community/sendgrid-provider.git", from: "2.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "PostgreSQLProvider", "FluentProvider", "LeafProvider", "Node", "Stripe", "LeafErrorMiddleware", "SendGridProvider"],
                exclude: [
                    "Config",
                    "Database",
                    "Localization",
                    "Public",
                    "Resources",
                    ]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
        .target(name: "Run", dependencies: ["App"])
    ]
)
