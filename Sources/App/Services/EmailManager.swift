//
//  Copyright © 2018 HomeKitty. All rights reserved.
//

import Vapor
import HTTP
import SendGrid

final class EmailManager {

    static func sendEmail(with reportRequest: ReportRequest, req: Request) throws -> Future<View> {
        // Create and send email.
        let myEmail = EmailAddress(email: "info@homekitty.world", name: reportRequest.name)
        let contactMessage = createContactMessage(for: reportRequest.topic, message: reportRequest.message, accessory: reportRequest.accessory)
        var sendGridEmail = SendGridEmail(from: EmailAddress(email: reportRequest.email, name: reportRequest.name), subject: contactMessage.topic.subject, content: [["type": "text/plain", "value": contactMessage.body]])

        sendGridEmail.personalizations = [Personalization(to: [myEmail])]

        let sendgrid = try req.make(SendGridClient.self)

        return try sendgrid.send([sendGridEmail], on: req.eventLoop).flatMap(to: View.self, {
            let leaf = try req.view()
            return leaf.render("reportSuccess")
        })
    }

    static private func createContactMessage(for topic: ContactTopic, message: String, accessory: String? = nil) -> ContactMessage {
        let body: String
        switch topic {
        case .accessoryIssue: body = "Accessory: \(String(describing: accessory ?? ""))\n\n\(message)"
        case .appIssue: body = "App: \(String(describing: accessory ?? ""))\n\n\(message)"
        case .feature, .partnership, .other: body = message
        }
        return ContactMessage(topic: topic, body: body)
    }
}
