//
//  MyFileManager.swift
//  RedditApp
//
//  Created by Соня Буділова on 26.02.2024.
//

import Foundation

class MyFileManager {
    static let manager: MyFileManager = .init()

    let docs = URL.documentsDirectory

    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let savedPostsFileURL: URL = URL.documentsDirectory.appendingPathComponent("savedPosts.json", isDirectory: false)

    private init() {
        print(savedPostsFileURL)
        if !FileManager.default.fileExists(atPath: savedPostsFileURL.path) {
            FileManager.default.createFile(atPath: savedPostsFileURL.path, contents: nil, attributes: nil)
        }
    }

    private func writeToFile(posts: [Post]) {
        if let encodedData = try? JSONEncoder().encode(posts) {
            do {
                try encodedData.write(to: savedPostsFileURL)
            } catch {
                print("ERROR: Failed to save posts to file: \(error)")
            }
        }
    }

    func writeToFile(post: Post) {
        var savedPosts: [Post] = []

        if let data = try? Data(contentsOf: savedPostsFileURL),
           let postsFromFile = try? JSONDecoder().decode([Post].self, from: data)
        {
            savedPosts = postsFromFile
        }

        savedPosts.append(post)

        if let encodedData = try? JSONEncoder().encode(savedPosts) {
            do {
                try encodedData.write(to: savedPostsFileURL)
                print("INFO: Saved post to file")
            } catch {
                print("ERROR: Failed to save post to file: \(error)")
            }
        }
    }

    func readFromFile() -> [Post] {
        var savedPosts: [Post] = []

        if let data = try? Data(contentsOf: savedPostsFileURL),
           let postsFromFile = try? JSONDecoder().decode([Post].self, from: data)
        {
            savedPosts = postsFromFile
        }

        return savedPosts
    }

    func removeFromFile(post: Post) {
        let posts = readFromFile()
        let postsAfterRemoval = posts.filter { $0 != post }

        if postsAfterRemoval.count == posts.count {
            print("ERROR: No such post was found to be removed from file")
        } else if posts.count - postsAfterRemoval.count > 1 {
            writeToFile(posts: postsAfterRemoval)
            print("ERROR: More than one post was found to be removed from file (and all of them were removed)")
        } else {
            writeToFile(posts: postsAfterRemoval)
            print("INFO: Removed post from file successfully")
        }
    }
}
