//
//  AddAccessoryAirplaySupport.swift
//  App
//
//  Created by Kim de Vos on 27/07/2018.
//

import FluentPostgreSQL

struct AddAccessoryAirplaySupport: PostgreSQLMigration {

    var supportsAirplay2: Bool

    enum CodingKeys: String, CodingKey {
        case supportsAirplay2 = "supports_airplay_2"
    }

    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return connection.simpleQuery("""
            ALTER TABLE \(Accessory.entity)
            ADD COLUMN supports_airplay_2 BOOLEAN NOT NULL DEFAULT False;
            """)
    }

    static func revert(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(Accessory.self, on: connection) { builder in
            builder.deleteField(for: \.supportsAirplay2)
        }
    }
}
