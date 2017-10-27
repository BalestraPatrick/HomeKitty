//
//  RSSFeed.swift
//  App
//
//  Created by Moritz Sternemann on 25.10.17.
//

import Vapor
import Foundation

struct RSSFeedGenerator {
    
    // MARK: - Properties
    let rfc822DateFormatter: DateFormatter
    let title: String
    let description: String
    let link: String
    let copyright: String?
    let imageURL: String?
    let path: String
    
    let xmlStart = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rss xmlns:dc=\"https://purl.org/dc/elements/1.1/\" xmlns:itunes=\"https://www.itunes.com/dtds/podcast-1.0.dtd\" version=\"2.0\">\n<channel>\n"
    let xmlEnd = "</channel>\n</rss>"
    
    
    // MARK: - Initializer
    
    init(title: String, description: String, link: String, copyright: String?, imageURL: String?, path: String) {
        self.title = title
        self.description = description
        self.link = link
        self.copyright = copyright
        self.imageURL = imageURL
        self.path = path
        
        rfc822DateFormatter = DateFormatter()
        rfc822DateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        rfc822DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        rfc822DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    }
    
    init(app: Droplet, path: String) {
        let link = app.config["rssfeed", "link"]?.string ?? ""
        let imageURLFromConfig = app.config["rssfeed", "imageURL"]?.string
        var imageURL: String?
        if imageURLFromConfig != nil {
            imageURL = "\(link)\(imageURLFromConfig!)"
        }
        
        self.init(title: app.config["rssfeed", "title"]?.string ?? "",
                  description: app.config["rssfeed", "description"]?.string ?? "",
                  link: link,
                  copyright: app.config["rssfeed", "copyright"]?.string,
                  imageURL: imageURL,
                  path: path)
    }
    
    // MARK: - Accessories Feed
    
    func accessoriesFeed(_ accessories: [Accessory]) throws -> String {
        var xmlFeed = xmlStart + getXMLMeta()

        if !accessories.isEmpty {
            let accessoryDate = accessories[0].date
            xmlFeed += "<pubDate>\(rfc822DateFormatter.string(from: accessoryDate))</pubDate>\n"
        }

        for accessory in accessories {
            xmlFeed += try accessory.getRSS(dateFormatter: rfc822DateFormatter, baseLink: link)
        }

        xmlFeed += xmlEnd

        return xmlFeed
    }
    
    // MARK: - Private Helper
    
    private func getXMLMeta() -> String {
        return
            "<title>\(title)</title>" +
            "<link>\(link + path)</link>" +
            "<description>\(description)</description>" +
            "<generator>HomeKitty</generator>" +
            "<image>" +
                "<url>\(imageURL ?? "")</url>" +
                "<title>HomeKitty Latest Accessories RSS Feed</title>" +
                "<link>\(link + path)</link>" +
            "</image>" +
            "<ttl>60</ttl>" +
            "<copyright>\(copyright ?? "(copyright)")</copyright>"
    }
    
}

extension Accessory {
    func getRSS(dateFormatter: DateFormatter, baseLink: String) throws -> String {
        var entry = "<item>\n"
        entry += "<title>\(name)</title>\n"
        entry += "<description>\n<![CDATA[\n"
        if let imageURL = URL(string: image, relativeTo: URL(string: baseLink)) {
            entry += "<img src=\"\(imageURL.absoluteString)\" />\n"
        }
        entry += "Price: \(price)\n"
        if let manufacturer = try manufacturer.get() {
            entry += "<p><a href=\"\(baseLink)/\(manufacturer.directLink)\">By \(manufacturer.name)</a></p>\n"
        }
        if !released {
            entry += "<i>Accessory or HomeKit support will be released soon.</i>\n"
        }
        entry += "]]></description>\n"
        entry += "<link>\(productLink)</link>\n"
        if let category = try category.get() {
            entry += "<category>\(category.name)</category>\n"
        }
        entry += "<pubDate>\(dateFormatter.string(from: date))</pubDate>\n"
        entry += "</item>\n"
        
        return entry
    }
}
