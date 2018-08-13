//
//  ReportRequest.swift
//  App
//
//  Created by Patrick Balestra on 8/13/18.
//

import Foundation

struct ReportRequest: Codable {
    let topic: ContactTopic
    let name: String
    let email: String
    let message: String
    let accessory: String
    let recaptchaResponse: String

    enum CodingKeys: String, CodingKey {
        case topic
        case name
        case email
        case message
        case accessory
        case recaptchaResponse = "g-recaptcha-response"
    }
}
