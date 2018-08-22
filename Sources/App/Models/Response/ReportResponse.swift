//
//  ReportResponse.swift
//  App
//
//  Created by Kim de Vos on 13/08/2018.
//

import Foundation

public struct ReportResponse: Codable {
    let accessories: [Accessory]
    let apps: [HomeKitApp]
    let accessoryToReport: Accessory.AccessoryResponse?
    let appToReport: HomeKitApp?
    let contactTopic: ContactTopic
}
