import Vapor
import FluentPostgreSQL

final class Region: PostgreSQLModel {
    static var entity = "regions"

    var name: String {
        let emoji: String
        switch shortName {
        case "US": emoji = "🇺🇸"
        case "UK": emoji = "🇬🇧"
        case "EU": emoji = "🇪🇺"
        case "AU": emoji = "🇦🇺"
        case "CN": emoji = "🇨🇳"
        default: emoji = ""
        }
        return [shortName, emoji].joined(separator: " ")
    }

    var id: Int?
    var shortName: String
    var fullName: String

    init(shortName: String, fullName: String) {
        self.shortName = shortName
        self.fullName = fullName
    }

    enum CodingKeys: String, CodingKey {
        case id
        case shortName = "short_name"
        case fullName = "full_name"
    }
}

// MARK: - Database Migration
extension Region: PostgreSQLMigration { }
