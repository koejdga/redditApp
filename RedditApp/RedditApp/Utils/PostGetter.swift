//
//  PostGetter.swift
//  RedditApp
//
//  Created by Соня Буділова on 16.02.2024.
//

import Foundation

class PostsGetter {
    var isPaginating = false

    private struct RedditPostUrl {
//        Example: https://www.reddit.com/r/ios/top.json?limit=1
        let startingPart = "https://www.reddit.com/r"
        var subreddit: String

        var limit: Int?
        var after: String?

        var url: String {
            let parameters = formParameters()
            return "\(startingPart)/\(subreddit)/top.json\(parameters)"
        }

        func formParameters() -> String {
            var parameters = "?"
            if let limit = limit {
                parameters.append(contentsOf: "limit=\(String(limit))&")
            }

            if let after = after {
                parameters.append(contentsOf: "after=\(String(after))&")
            }

            return String(parameters.dropLast())
        }
    }

    func getRedditPosts(subreddit: String, limit: Int?, after: String?, completion: @escaping (Result<[Post], NetworkError>) -> Void) {
        isPaginating = true
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let redditPostUrl = RedditPostUrl(subreddit: subreddit, limit: limit, after: after)
            self.fetchPostData(url: redditPostUrl.url) { result in
                completion(result)
                self.isPaginating = false
            }
        }
    }

    private func fetchPostData(url: String, completion: @escaping (Result<[Post], NetworkError>) -> Void) {
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
                let decodedResponse = try JSONDecoder().decode(RedditResponse.self, from: data)
                let posts = decodedResponse.data.children.map { $0.data }
                completion(.success(posts))
            } catch {
                completion(.failure(.notDecoded))
                print("ERROR: Unable to decode fetched info")
            }
        }.resume()
    }
}
