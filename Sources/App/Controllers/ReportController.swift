//
//  Copyright © 2018 HomeKitty. All rights reserved.
//

import Vapor
import HTTP
import FluentPostgreSQL
import Leaf

final class ReportController {

    init(router: Router) {
        router.get("report", use: report)
        router.post("report","submit", use: submit)
    }

    func report(_ req: Request) throws -> Future<View> {
        let accessories = try QueryHelper.accessories(request: req).all()
        let apps = try QueryHelper.apps(request: req)

        return flatMap(to: View.self, accessories, apps, { (accessories, apps) in
            let leaf = try req.view()
            let responseData = ReportResponse(accessories: accessories.map { $0.0 },
                                              apps: apps,
                                              accessoryToReport: nil,
                                              appToReport: nil,
                                              contactTopic: .accessoryIssue)
            return leaf.render("report", responseData)
        })
    }

    func submit(_ req: Request) throws -> Future<View> {
        return try req.content.decode(ReportRequest.self).flatMap(to: View.self, { reportRequest in
            return try RecaptchaManager.verify(with: req, recaptchaResponse: reportRequest.recaptchaResponse).flatMap { result in
                // Recaptcha failed, simply redirect to the report page.
                guard result else { return try self.report(req) }
                return try EmailManager.sendEmail(with: reportRequest, req: req)
            }
        })
    }
}
