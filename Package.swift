// swift-tools-version:4.1

import PackageDescription

let package = Package(
    name: "HomeKitty",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent.git", from: "3.0.0-rc"),

        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor-community/stripe-provider.git", from: "2.0.0-rc"),
//        .package(url: "https://github.com/brokenhandsio/leaf-error-middleware.git", from: "0.1.0"),
//        .package(url: "https://github.com/vapor-community/sendgrid-provider.git", from: "2.2.1")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor",
                                            "Fluent",
                                            "FluentPostgreSQL",
                                            "Leaf",
                                            "Stripe"],
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
