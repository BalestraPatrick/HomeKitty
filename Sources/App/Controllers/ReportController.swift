//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import HTTP
import SMTP
import SendGridProvider

final class ReportController {

    var droplet: Droplet!

    func addRoutes(droplet: Droplet) {
        self.droplet = droplet
        let group = droplet.grouped("report")
        group.get(handler: report)
        group.post("submit", handler: submit)
    }

    func report(request: Request) throws -> ResponseRepresentable {
        let accessories = try Accessory.makeQuery().filter("approved", true).all().sorted(by: { $0.name.compare($1.name) == .orderedAscending })
        let nodes = try Node(node: [
            "accessories": accessories.makeNode(in: nil),
        ])
        return try droplet.view.make("report", nodes)
    }

    func submit(request: Request) throws -> ResponseRepresentable {
        guard let topic = ContactTopic(request.formURLEncoded?["topic"]?.string) else { throw Abort.badRequest }
        guard let name = request.formURLEncoded?["name"]?.string else { throw Abort.badRequest }
        guard let email = request.formURLEncoded?["email"]?.string else { throw Abort.badRequest }
        guard let message = request.formURLEncoded?["message"]?.string else { throw Abort.badRequest }
        let accessory = request.formURLEncoded?["accessory"]?.string
        guard let sendgrid = droplet.mail as? SendGrid else { throw Abort.serverError }

        // Create and send email.
        let myEmail = EmailAddress(name: name, address: "info@homekitty.world")
        let contactMessage = self.contactMessage(for: topic, message: message, accessory: accessory)
        let sendGridEmail = SendGridEmail(from: email, subject: contactMessage.topic.subject, body: contactMessage.body)
        sendGridEmail.personalizations = [Personalization(to: [myEmail])]
        try sendgrid.send([sendGridEmail])

        // Render success/failure page.
        let node = try Node(node: ["success": true])
        return try droplet.view.make("report", node)
    }

    private func contactMessage(for topic: ContactTopic, message: String, accessory: String? = nil) -> ContactMessage {
        let body: String
        switch topic {
        case .issue: body = "Accessory: \(String(describing: accessory ?? ""))\n\n\(message)"
        case .feature, .partnership, .other: body = message
        }
        return ContactMessage(topic: topic, body: body)
    }
}
