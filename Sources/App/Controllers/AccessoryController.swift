//
//  Copyright © HomeKitty. All rights reserved.
//

import Foundation
import Vapor
import HTTP
import FluentPostgreSQL
import Leaf
import Fluent
import SendGrid

final class AccessoryController {
    
    init(router: Router) {
        router.get("accessories", Int.parameter, use: accessory)
        router.get("accessories", Int.parameter, "report", use: report)
        router.post("accessories", Int.parameter, "report", use: submitReport)
        router.get("accessories", use: accessories)
        router.get("accessory", use: oldAccessory)
    }
    
    func accessories(_ req: Request) throws -> Future<View> {
        let categories = try QueryHelper.categories(request: req)
        let manufacturerCount = try QueryHelper.manufacturerCount(request: req)
        let accessories = try QueryHelper.accessories(request: req).all()

        return flatMap(to: View.self, categories, manufacturerCount, accessories) { categories, manufacturersCount, accessories in
            let data = AccessoriesResponse(noAccessoriesFound: accessories.isEmpty,
                accessories: accessories.map { Accessory.AccessoryResponse(accessory: $0.0, manufacturer: $0.1) },
                                           categories: categories,
                                           accessoryCount: accessories.count,
                                           manufacturerCount: manufacturersCount, accessoriesSelected: true)
            let leaf = try req.view()
            return leaf.render("accessories", data)
        }
    }
    
    func accessory(_ req: Request) throws -> Future<View> {
        let paramId: Int = try req.parameters.next()
        
        let accessory = try QueryHelper.accessory(request: req, id: paramId)
        let categories = try QueryHelper.categories(request: req)
        let manufacturersCount = try QueryHelper.manufacturerCount(request: req)
        let accessoryCount = try QueryHelper.accessoriesCount(request: req)
        
        return accessory.flatMap(to: View.self) { accessory in
            guard let accessory = accessory else { throw Abort(.notFound) }
            
            return flatMap(to: View.self, categories, manufacturersCount, accessoryCount) { (categories, manufacturersCount, accessoryCount) in
                let data = AccessoryResponse(pageIcon: categories.first(where: { $0.id == accessory.0.categoryId })?.image ?? "",
                                             accessory: Accessory.AccessoryResponse(accessory: accessory.0, manufacturer: accessory.1),
                                             categories: categories,
                                             accessoryCount: accessoryCount,
                                             manufacturerCount: manufacturersCount)

                let leaf = try req.view()
                return leaf.render("accessory", data)
            }
        }
    }

    func oldAccessory(_ req: Request) throws -> Future<Response> {
        let paramName: String = try req.query.get(at: "name")

        return Accessory.query(on: req).filter(\Accessory.name == paramName).first().map { accessory in
            return req.redirect(to: "accessories/\(accessory?.id ?? -1)")
        }
    }

    // MARK: - Report
    func report(_ req: Request) throws -> Future<View> {
        let accessoryId: Int = try req.parameters.next()
        let accessory = try QueryHelper.accessory(request: req, id: accessoryId)

        return accessory.flatMap(to: View.self) { accessory in
            guard let accessory = accessory else { throw Abort(.badRequest) }
            let leaf = try req.view()
            let responseData = ReportResponse(accessory: Accessory.AccessoryResponse(accessory: accessory.0, manufacturer: accessory.1) )
            return leaf.render("accessory/accessoryReport", responseData)
        }
    }

    func submitReport(_ req: Request) throws -> Future<View> {
        return try req.content.decode(ReportRequest.self).flatMap(to: View.self, { reportRequest in
            return try RecaptchaManager.verify(with: req, recaptchaResponse: reportRequest.recaptchaResponse).flatMap { result in
                let accessoryId: Int = try req.parameters.next()
                return Accessory.query(on: req).filter(\.id == accessoryId).first().flatMap { accessory in
                    // Recaptcha failed, simply redirect to the report page.
                    guard result else { return try self.report(req) }
                    // Create and send email.
                    let myEmail = EmailAddress(email: "info@homekitty.world", name: reportRequest.name)

                    let body = """
                    AccessoryId: \(accessoryId)
                    Accessory: \( accessory?.name ?? "null")

                    
                    \(reportRequest.message)
                    """

                    var sendGridEmail = SendGridEmail(from: EmailAddress(email: reportRequest.email, name: reportRequest.name), subject: ContactTopic.issue.subject, content: [["type": "text/plain", "value": body]])

                    sendGridEmail.personalizations = [Personalization(to: [myEmail])]

                    let sendgrid = try req.make(SendGridClient.self)

                    return try sendgrid.send([sendGridEmail], on: req.eventLoop).flatMap(to: View.self, {
                        let leaf = try req.view()
                        return leaf.render("reportSuccess")
                    })
                }
            }
        })
    }

    // MARK: - Private

    private struct ReportResponse: Codable {
        let accessory: Accessory.AccessoryResponse
    }

    private struct ReportRequest: Codable {
        let name: String
        let email: String
        let message: String
        let recaptchaResponse: String

        enum CodingKeys: String, CodingKey {
            case name
            case email
            case message
            case recaptchaResponse = "g-recaptcha-response"
        }
    }

    private struct AccessoryResponse: Codable {
        let pageTitle = "Accessory Details"
        let pageIcon: String
        let accessory: Accessory.AccessoryResponse
        let categories: [Category]
        let accessoryCount: Int
        let manufacturerCount: Int
    }
    
    private struct AccessoriesResponse: Codable {
        let noAccessoriesFound: Bool
        let accessories: [Accessory.AccessoryResponse]
        let categories: [Category]
        let accessoryCount: Int
        let manufacturerCount: Int
        let accessoriesSelected: Bool
    }
}
