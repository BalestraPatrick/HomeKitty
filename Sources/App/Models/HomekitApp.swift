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

    struct HomekitAppResponse: Codable {
        let name: String
        let artwork: String
        let developer: String
        let appStoreUrl: String
        let description: String

        init(itunesApp: ItunesApp) {
            self.name = itunesApp.trackName
            self.artwork = itunesApp.artworkUrl512 ?? itunesApp.artworkUrl100 ?? itunesApp.artworkUrl60 ?? ""
            self.developer = itunesApp.artistName ?? itunesApp.sellerName
            self.appStoreUrl = itunesApp.trackViewUrl
            self.description = itunesApp.description
        }
    }
}

extension HomekitApp: PostgreSQLMigration { }
