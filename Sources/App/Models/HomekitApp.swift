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
    var description: String
    var developer: String
    var developerWebsite: String
    var appStoreLink: String
    var appIcon: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case developer
        case developerWebsite = "developer_website"
        case appStoreLink = "app_store_link"
        case appIcon = "app_icon"
    }
}

extension HomekitApp: PostgreSQLMigration { }
