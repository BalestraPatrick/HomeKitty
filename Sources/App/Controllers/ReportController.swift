//
//  Copyright © 2018 HomeKitty. All rights reserved.
//

import Vapor
import HTTP
import FluentPostgreSQL
import Leaf
import SendGrid

final class ReportController {

    init(router: Router) {
        router.get("report", use: report)
        router.post("report","submit", use: submit)
    }

    func report(_ req: Request) throws -> Future<View> {
        let accessories = Accessory.query(on: req).filter(\Accessory.approved == true).sort(\Accessory.name, .ascending).all()

        return accessories.flatMap(to: View.self) { accessories in
            let leaf = try req.view()
            let responseData = ReportResponse(accessories: accessories)
            return leaf.render("report", responseData)
        }
    }

    func submit(_ req: Request) throws -> Future<View> {
        return try req.content.decode(ReportRequest.self).flatMap(to: View.self, { reportRequest in
            return try RecaptchaManager.verify(with: req, recaptchaResponse: reportRequest.recaptchaResponse).flatMap { result in
                // Recaptcha failed, simply redirect to the report page.
                guard result else { return try self.report(req) }
                // Create and send email.
                let myEmail = EmailAddress(email: "info@homekitty.world", name: reportRequest.name)
                let contactMessage = self.contactMessage(for: reportRequest.topic, message: reportRequest.message, accessory: reportRequest.accessory)
                var sendGridEmail = SendGridEmail(from: EmailAddress(email: reportRequest.email, name: reportRequest.name), subject: contactMessage.topic.subject, content: [["type": "text/plain", "value": contactMessage.body]])

                sendGridEmail.personalizations = [Personalization(to: [myEmail])]

                let sendgrid = try req.make(SendGridClient.self)

                return try sendgrid.send([sendGridEmail], on: req.eventLoop).flatMap(to: View.self, {
                    let leaf = try req.view()
                    return leaf.render("report", ["success": true])
                })
            }
        })
    }
    
    private func contactMessage(for topic: ContactTopic, message: String, accessory: String? = nil) -> ContactMessage {
        let body: String
        switch topic {
        case .issue: body = "Accessory: \(String(describing: accessory ?? ""))\n\n\(message)"
        case .feature, .partnership, .other: body = message
        }
        return ContactMessage(topic: topic, body: body)
    }

    private struct ReportResponse: Codable {
        let accessories: [Accessory]
    }

    private struct ReportRequest: Codable {
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
}
