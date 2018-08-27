//
//  Copyright © 2018 HomeKitty. All rights reserved.
//

import Foundation

enum ContactTopic: String, Codable {
    case accessoryIssue = "accessory-issue"
    case appIssue = "app-issue"
    case feature
    case partnership
    case other

    init?(_ rawValue: String?) {
        self.init(rawValue: rawValue ?? "")
    }

    var subject: String {
        switch self {
        case .accessoryIssue: return "HomeKitty - Accessory Issue"
        case .appIssue: return "HomeKitty - App Issue"
        case .feature: return "HomeKitty - Feature Request"
        case .partnership: return "HomeKitty - Partnership"
        case .other: return "HomeKitty - Other"
        }
    }
}

struct ContactMessage {
    let topic: ContactTopic
    let body: String
}
