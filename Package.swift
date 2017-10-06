import PackageDescription

let package = Package(
    name: "HomeKitty",
    targets: [
        Target(name: "App"),
        Target(name: "Run", dependencies: ["App"])
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor-community/postgresql-provider.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/fluent-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/leaf-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/node.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor-community/stripe.git", Version(1, 0, 0, prereleaseIdentifiers: ["beta"])),
        .Package(url: "https://github.com/brokenhandsio/leaf-error-middleware.git", majorVersion: 0),
        .Package(url: "https://github.com/vapor-community/sendgrid-provider.git", majorVersion: 2)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)
