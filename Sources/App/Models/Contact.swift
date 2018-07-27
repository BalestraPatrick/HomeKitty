//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Foundation

enum ContactTopic: String, Codable {
    case issue
    case feature
    case partnership
    case other

    init?(_ rawValue: String?) {
        self.init(rawValue: rawValue ?? "")
    }

    var subject: String {
        switch self {
        case .issue: return "HomeKitty - Accessory Issue"
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
