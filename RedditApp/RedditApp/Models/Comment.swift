//
//  Comment.swift
//  RedditAppSwiftUI
//
//  Created by Соня Буділова on 19.03.2024.
//

import Foundation
struct Listing: Codable {
    let data: CommentData
}

struct CommentData: Codable {
    let children: [CommentWrapper]
}

struct CommentWrapper: Codable {
    let data: Comment
}

struct Comment: Codable, Hashable {
    let author: String
    let created: Int
    let body: String
    let ups: Int
    let downs: Int
    let id: String
    var rating: Int {
        ups + downs
    }

    let permalink: String

    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(created))
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
