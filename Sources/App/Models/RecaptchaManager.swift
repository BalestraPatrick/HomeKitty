//
//  Copyright © 2018 HomeKitty. All rights reserved.
//

import Vapor

final class RecaptchaManager {

    struct RecaptchaResponse: Content {
        let success: Bool
    }

    static func verify(with req: Request, recaptchaResponse: String) throws -> Future<Bool> {
        guard let recaptchaSecret = Environment.get("RECAPTCHA_SECRET") else { throw Abort(.badRequest, reason: "RECAPTCHA_SECRET not found") }
        let client = try req.client()
        return client
            .post("https://www.google.com/recaptcha/api/siteverify?secret=\(recaptchaSecret)&response=\(recaptchaResponse)")
            .flatMap { response in
                return try response.content.decode(RecaptchaResponse.self).map { $0.success }
        }
    }
}
