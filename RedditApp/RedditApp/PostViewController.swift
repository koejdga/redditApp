//
//  PostViewController.swift
//  RedditApp
//
//  Created by Соня Буділова on 12.02.2024.
//

import SDWebImage
import UIKit

class PostViewController: UIViewController {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var timePassedLabel: UILabel!
    @IBOutlet var domainLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var commentsLabel: UILabel!
    @IBOutlet var previewImage: UIImageView!
    @IBOutlet var saveButton: UIButton!
    
    let postsGetter = PostsGetter()
    var postIsSaved: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postsGetter.getRedditPosts(subreddit: "ios", limit: 1, after: nil) { post in
            DispatchQueue.main.async {
                if let post = post {
                    self.usernameLabel.text = post.author_fullname
                    self.timePassedLabel.text = post.timePassed
                    self.domainLabel.text = post.domain
                    self.titleLabel.text = post.title
                    self.ratingLabel.text = String(post.ups + post.downs)
                    self.commentsLabel.text = String(post.num_comments)
                    
                    let url = URL(string: post.preview.images[0].source.url)
                    self.previewImage.sd_setImage(with: url)
                    
                    self.postIsSaved = post.saved
                    self.saveButton.addTarget(self, action: #selector(self.toggleSaveButton), for: .touchUpInside)
                    
                } else {
                    print("ERROR: Could not load post info in UI")
                }
            }
        }
    }
    
    @objc func toggleSaveButton() {
        postIsSaved = !postIsSaved
        let buttonImage = postIsSaved ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
        saveButton.setImage(buttonImage, for: .normal)
    }
}

class PostsGetter {
    struct RedditPostUrl {
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
    
    func getRedditPosts(subreddit: String, limit: Int?, after: String?, completion: @escaping (Post?) -> Void) {
        let redditPostUrl = RedditPostUrl(subreddit: subreddit, limit: limit, after: after)
        fetchPostData(url: redditPostUrl.url) { post in
            completion(post)
        }
    }
    
    func fetchPostData(url: String, completion: @escaping (Post?) -> Void) {
        guard let url = URL(string: url)
        else {
            print("ERROR: Incorrect url")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data else {
                print("ERROR: Unable to fetch post")
                completion(nil)
                return
            }
                
            do {
                let decodedResponse = try JSONDecoder().decode(RedditResponse.self, from: data)
                let posts = decodedResponse.data.children.map { $0.data }
                completion(posts[0])
            } catch {
                completion(nil)
                print("ERROR: Unable to decode fetched info")
            }
        }.resume()
    }
}

struct RedditResponse: Codable {
    let data: RedditData
}

struct RedditData: Codable {
    let children: [PostWrapper]
}

struct PostWrapper: Codable {
    let data: Post
}

struct Post: Codable {
    let title: String
    let author_fullname: String
    let domain: String
    let preview: ImagePreview
    let created_utc: Int
    let ups: Int
    let downs: Int
    let num_comments: Int
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
    let images: [Image]
}

struct Image: Codable {
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
