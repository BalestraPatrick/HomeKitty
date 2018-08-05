//
//  HomekitApp.swift
//  App
//
//  Created by Kim de Vos on 28/07/2018.
//

import Foundation
import FluentPostgreSQL
import Vapor

struct HomekitApp: PostgreSQLModel {
    static var entity = "homekit_apps"

    var id: Int?
    let name: String
    let subtitle: String?
    let appStoreId: String
    let appStoreIcon: String?
    let approved: Bool
    let createdAt: Date
    let updatedAt: Date

    init(name: String, subtitle: String?, appStoreId: String, appStoreIcon: String?) {
        self.name = name
        self.subtitle = subtitle
        self.appStoreId = appStoreId
        self.appStoreIcon = appStoreIcon
        self.approved = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case subtitle
        case appStoreId = "app_store_id"
        case appStoreIcon = "app_store_icon"
        case approved
        case createdAt
        case updatedAt
    }
}

extension HomekitApp: PostgreSQLMigration { }
