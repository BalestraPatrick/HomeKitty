//
//  Copyright © 2017 HomeKitty. All rights reserved.
//

import Foundation

public struct ReportResponse: Codable {
    let accessories: [Accessory]
    let apps: [HomeKitApp]
    let accessoryToReport: Accessory.AccessoryResponse?
    let appToReport: HomeKitApp?
    let contactTopic: ContactTopic
}
