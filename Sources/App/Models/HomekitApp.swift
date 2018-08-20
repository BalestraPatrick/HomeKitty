//
//  HomeKitApp.swift
//  App
//
//  Created by Kim de Vos on 28/07/2018.
//

import Foundation
import FluentPostgreSQL
import Vapor

struct HomeKitApp: PostgreSQLModel {
    static var entity = "apps"

    var id: Int?
    let name: String
    let subtitle: String?
    let publisher: String
    let publisherLink: String
    let price: Double?
    let appStoreLink: String
    let appStoreIcon: String
    let approved: Bool
    let createdAt: Date
    let updatedAt: Date

    init(name: String,
         subtitle: String?,
         price: Double?,
         appStoreLink: String,
         appStoreIcon: String,
         publisher: String,
         publisherLink: String) {
        self.name = name
        self.subtitle = subtitle
        self.publisher = publisher
        self.publisherLink = publisherLink
        self.price = price
        self.appStoreLink = appStoreLink
        self.appStoreIcon = appStoreIcon
        self.approved = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case subtitle
        case publisher
        case publisherLink = "publisher_link"
        case price
        case appStoreLink = "app_store_link"
        case appStoreIcon = "app_store_icon"
        case approved
        case createdAt
        case updatedAt
    }
}

extension HomeKitApp: PostgreSQLMigration { }
