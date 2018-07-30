//
//  ItunesApp.swift
//  App
//
//  Created by Kim de Vos on 29/07/2018.
//

import Foundation
import Vapor

private struct ItunesReponse: Content {
    let results: [ItunesApp]
}

struct ItunesApp: Content {

    let artworkUrl60: String?
    let artworkUrl100: String?
    let artworkUrl512: String?
    let sellerUrl: String?
    let sellerName: String
    let artistName: String?
    let minimumOsVersion: String
    let trackName: String
    let description: String
    let formattedPrice: String
    let trackViewUrl: String

    static func fetchItunesApp(req: Request, appStoreId: String) throws -> Future<ItunesApp?> {
        let client = try req.client()

        return client.get("https://itunes.apple.com/lookup?id=\(appStoreId.replacingOccurrences(of: "id", with: ""))")
            .map { response in
                guard let data = response.http.body.data else { throw Abort(.badRequest) }
                let jsonDecoder = JSONDecoder()
                return try jsonDecoder.decode(ItunesReponse.self, from: data).results.first
        }
    }

}
