//
//  HomekitApp.swift
//  App
//
//  Created by Kim de Vos on 28/07/2018.
//

import Foundation
import FluentPostgreSQL

struct HomekitApp: PostgreSQLModel {
    static var entity = "homekit_apps"

    var id: Int?
    var name: String
    var appStoreId: String
    var appStoreIcon: String
    var approved: Bool
    var date: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case appStoreId = "app_store_id"
        case appStoreIcon = "app_store_icon"
        case approved
        case date
    }
}

extension HomekitApp: PostgreSQLMigration { }
