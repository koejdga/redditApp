//
//  PostListViewController.swift
//  RedditApp
//
//  Created by Соня Буділова on 16.02.2024.
//

import UIKit

class PostListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    let postsGetter = PostsGetter()
    var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        postsGetter.getRedditPosts(subreddit: "ios", limit: 1, after: nil) { post in
            DispatchQueue.main.async {
                if let post = post {
                    self.posts.append(post)
                    self.tableView.reloadData()
                } else {
                    print("ERROR: Could not load post info in UI")
                }
            }
        }
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}

extension PostListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "redditPostCell", for: indexPath) as! PostTableViewCell
        if !posts.isEmpty {
            cell.configure(for: posts[0])
        }

        return cell
    }
}
