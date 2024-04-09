//
//  Post.swift
//  RedditApp
//
//  Created by Соня Буділова on 16.02.2024.
//

import Foundation

struct RedditResponse: Codable {
    let data: RedditData
}

struct RedditData: Codable {
    let children: [PostWrapper]
}

struct PostWrapper: Codable {
    let data: Post
}

struct Post: Codable, Equatable {
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.name == rhs.name
    }

    let title: String
    let author_fullname: String?
    let domain: String
    let preview: ImagePreview?
    let created_utc: Int
    let ups: Int
    let downs: Int
    let num_comments: Int
    let permalink: String

    let name: String
    let subreddit: String
    let id: String

    var after: String {
        return name
    }

    var rating: Int {
        return ups + downs
    }

    var image_url: URL? {
        if let url = preview?.images[0].source.url {
            return URL(string: url)
        }
        return nil
    }

    var saved: Bool = false

    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(created_utc))
    }

    var timePassed: String {
        let secondsAgo = Int(Date().timeIntervalSince(date))
        if secondsAgo < 60 {
            return "\(secondsAgo)s"
        } else if secondsAgo < 3600 {
            return "\(secondsAgo / 60)m"
        } else if secondsAgo < 86400 {
            return "\(secondsAgo / 3600)h"
        } else {
            return "\(secondsAgo / 86400)d"
        }
    }
}

struct ImagePreview: Codable {
    let images: [ImageForPost]
}

struct ImageForPost: Codable {
    let source: ImageSource
}

struct ImageSource: Codable {
    let url: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let originalURL = try container.decode(String.self, forKey: .url)
        self.url = originalURL.replacingOccurrences(of: "&amp;", with: "&")
    }
}
