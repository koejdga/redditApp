
//
//  PostGetter.swift
//  RedditApp
//
//  Created by Соня Буділова on 16.02.2024.
//

import Foundation

class CommentGetter {
    var isPaginating = false

    struct RedditCommentUrl {
//        Example: https://www.reddit.com/r/ios/comments/1bi2gal/.json
        let startingPart = "https://www.reddit.com/r"
        var subreddit: String
        var postId: String

        var url: String {
            return "\(startingPart)/\(subreddit)/comments/\(postId)/.json"
        }
    }

    enum NetworkError: Error {
        case invalidURL
        case noData
        case notDecoded
    }

    func getRedditComments(subreddit: String?, postId: String?, completion: @escaping (Result<[Comment], NetworkError>) -> Void) {
        guard let subreddit = subreddit, let postId = postId
        else {
            completion(.failure(.noData))
            return
        }

        isPaginating = true
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let redditCommentUrl = RedditCommentUrl(subreddit: subreddit, postId: postId)
            self.fetchCommentData(url: redditCommentUrl.url) { result in
                completion(result)
                self.isPaginating = false
            }
        }
    }

    private func fetchCommentData(url: String, completion: @escaping (Result<[Comment], NetworkError>) -> Void) {
        guard let url = URL(string: url)
        else {
            completion(.failure(.invalidURL))
            print("ERROR: Incorrect url")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data else {
                completion(.failure(.noData))
                print("ERROR: Unable to fetch post")
                return
            }

            do {
                guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                    fatalError("Failed to parse JSON")
                }

                guard jsonArray.count >= 2 else {
                    fatalError("ERROR: Insufficient elements in the array")
                }

                let secondElementData = try JSONSerialization.data(withJSONObject: jsonArray[1], options: [])
                let decodedSecondListing = try JSONDecoder().decode(Listing.self, from: secondElementData)

                let comments = decodedSecondListing.data.children.map { $0.data }
                completion(.success(comments))

            } catch {
                completion(.failure(.notDecoded))
                print("ERROR: Unable to decode JSON")
                print("\(error)")
            }

        }.resume()
    }
}
