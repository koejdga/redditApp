//
//  PostListViewController.swift
//  RedditApp
//
//  Created by Соня Буділова on 16.02.2024.
//

import UIKit

class PostListViewController: UIViewController {
    enum Const {
        static let cellReuseIdentifier = "reddit_post_cell"
        static let segueIdentifier = "go_to_post_details"
    }

    @IBOutlet var tableView: UITableView!
    @IBOutlet var subredditLabel: UILabel!

    let postsGetter = PostsGetter()
    var posts: [Post] = []
    var lastSelectedPost: Post?
    let subreddit: String = "ios"
    var lastAfter: String? {
        return posts.last?.after
    }

    let limit = 2

    override func viewDidLoad() {
        super.viewDidLoad()

        subredditLabel.text = "/r/\(subreddit)"
        getAndLoadPosts()
    }

    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))

        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()

        return footerView
    }

    func getAndLoadPosts() {
        postsGetter.getRedditPosts(subreddit: subreddit, limit: limit, after: lastAfter) { [weak self] result in
            switch result {
            case .success(let posts):
                DispatchQueue.main.async {
                    self?.posts.append(contentsOf: posts)
                    self?.tableView.reloadData()
                    self?.tableView.tableFooterView = nil
                }
            case .failure:
                break
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.

        switch segue.identifier {
        case Const.segueIdentifier:
            let nextVc = segue.destination as! PostDetailsViewController
            DispatchQueue.main.async {
                if let lastSelectedPost = self.lastSelectedPost {
                    nextVc.configure(with: lastSelectedPost)
                }
            }
        default:
            break
        }
    }
}

extension PostListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.cellReuseIdentifier, for: indexPath) as! PostTableViewCell
        if !posts.isEmpty {
            cell.configure(with: posts[indexPath.row])
        }

        return cell
    }
}

extension PostListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedPost = posts[indexPath.row]
        performSegue(withIdentifier: Const.segueIdentifier, sender: nil)
    }
}

extension PostListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > tableView.contentSize.height - 100 - scrollView.frame.size.height {
            if !postsGetter.isPaginating {
                tableView.tableFooterView = createSpinnerFooter()
                getAndLoadPosts()
            }
        }
    }
}
