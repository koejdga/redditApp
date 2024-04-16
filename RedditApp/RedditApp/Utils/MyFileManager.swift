//
//  MyFileManager.swift
//  RedditApp
//
//  Created by Соня Буділова on 26.02.2024.
//

import Foundation

class MyFileManager {
    static let manager: MyFileManager = .init()
    private let savedPostsFileURL: URL = URL.documentsDirectory.appendingPathComponent("savedPosts.json", isDirectory: false)
    private(set) var savedPosts: [Post] = []

    private init() {
        print(savedPostsFileURL)
        if !FileManager.default.fileExists(atPath: savedPostsFileURL.path) {
            FileManager.default.createFile(atPath: savedPostsFileURL.path, contents: nil, attributes: nil)
        }
        readFromFile()
    }

    func addSavedPost(post: Post) {
        if savedPosts.contains(post) {
            print("ERROR: Unable to add post to saved posts since it is already there")
        } else {
            savedPosts.append(post)
        }
    }

    func removeSavedPost(post: Post) {
        let postsAfterRemoval = savedPosts.filter { $0 != post }

        if postsAfterRemoval.count == savedPosts.count {
            print("ERROR: No such post was found to be removed from saved posts")
        } else if savedPosts.count - postsAfterRemoval.count > 1 {
            print("ERROR: More than one post was found to be removed from saved posts (and all of them were removed)")
        } else {
            print("INFO: Removed post from saved posts successfully")
        }

        savedPosts = postsAfterRemoval
    }

    func writeToFile() {
        if let encodedData = try? JSONEncoder().encode(savedPosts) {
            do {
                try encodedData.write(to: savedPostsFileURL)
            } catch {
                print("ERROR: Failed to save posts to file: \(error)")
            }
        } else {
            print("ERROR: Failed to encode saved posts, saved posts were not saved to file")
        }
    }

    private func readFromFile() {
        if let data = try? Data(contentsOf: savedPostsFileURL),
           let postsFromFile = try? JSONDecoder().decode([Post].self, from: data)
        {
            savedPosts = postsFromFile
        } else {
            print("ERROR: Unable to read saved posts from file")
        }
    }
}
