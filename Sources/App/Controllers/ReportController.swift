//
//  Copyright © 2018 Kim de Vos. All rights reserved.
//

import Vapor
import HTTP
import FluentPostgreSQL
import Leaf
//import SMTP
//import SendGridProvider

final class ReportController {

    init(router: Router) {
        router.get("report", use: report)
        router.post("report","submit", use: submit)
        // group.get(handler: report)
        // group.post("submit", handler: submit)
    }

        func report(_ req: Request) throws -> Future<View> {
            let accessories = try Accessory.query(on: req).filter(\Accessory.approved == true).sort(\Accessory.name, .ascending).all()

            return accessories.flatMap(to: View.self) { accessories in
                let leaf = try req.make(LeafRenderer.self)
                let responseData = ReportResponse(accessories: accessories)

                return leaf.render("report", responseData)
            }
        }

        func submit(_ req: Request) throws -> Future<View> {

//            guard let topic = ContactTopic(request.formURLEncoded?["topic"]?.string) else { throw Abort.badRequest }
//            guard let name = request.formURLEncoded?["name"]?.string else { throw Abort.badRequest }
//            guard let email = request.formURLEncoded?["email"]?.string else { throw Abort.badRequest }
//            guard let message = request.formURLEncoded?["message"]?.string else { throw Abort.badRequest }
//            let accessory = request.formURLEncoded?["accessory"]?.string
//            guard let sendgrid = droplet.mail as? SendGrid else { throw Abort.serverError }
//
//            // Create and send email.
//            let myEmail = EmailAddress(name: name, address: "info@homekitty.world")
//            let contactMessage = self.contactMessage(for: topic, message: message, accessory: accessory)
//            let sendGridEmail = SendGridEmail(from: email, subject: contactMessage.topic.subject, body: contactMessage.body)
//            sendGridEmail.personalizations = [Personalization(to: [myEmail])]
//            try sendgrid.send([sendGridEmail])

            return try req.content.decode(ReportRequest.self).flatMap(to: View.self) { data in
                let leaf = try req.make(LeafRenderer.self)

                return leaf.render("report", ["success": true])
            }
        }
    
    //    private func contactMessage(for topic: ContactTopic, message: String, accessory: String? = nil) -> ContactMessage {
    //        let body: String
    //        switch topic {
    //        case .issue: body = "Accessory: \(String(describing: accessory ?? ""))\n\n\(message)"
    //        case .feature, .partnership, .other: body = message
    //        }
    //        return ContactMessage(topic: topic, body: body)
    //    }

    private struct ReportResponse: Codable {
        let accessories: [Accessory]
    }

    private struct ReportRequest: Codable {
        let topic: String
        let name: String
        let email: String
        let message: String
        let accessory: String
    }
}
