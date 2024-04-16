//
//  PostListViewController.swift
//  RedditApp
//
//  Created by Соня Буділова on 16.02.2024.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDataSource, PostViewDelegate, SelectedPostDelegate, UIScrollViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {
    // MARK: - Static

    private enum Const {
        static let cellReuseIdentifier = "reddit_post_cell"
        static let segueIdentifier = "go_to_post_details"
    }

    // MARK: - IBOutlets

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchBar: UISearchBar!

    // MARK: - Properties

    private let postsGetter = PostsGetter()
    private var posts: [Post] = []
    private var lastSelectedPost: Post?
    private let subreddit: String = "ios"
    private var lastAfter: String? {
        return posts.last?.after
    }

    private var showOnlySavedPosts = false {
        didSet {
            if !showOnlySavedPosts {
                posts = []
                getAndLoadPosts()
            }
        }
    }

    private let limit = 5

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "/r/\(subreddit)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "bookmark.circle"),
            style: .plain,
            target: self,
            action: #selector(showSavedPosts)
        )

//        TODO: move this to another file maybe (separate view or i don't know)
        let button = UIButton(type: .custom)
        button.tintColor = .systemYellow
        let iconImage = UIImage(systemName: "circle.fill")
        button.setImage(iconImage, for: .normal)
        button.setImage(iconImage, for: .highlighted)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)

        var firstTime = true
        _ = NetworkChecker(onNetworkAvailable: {
            DispatchQueue.main.async { [weak self] in
                self?.getAndLoadPosts()
                button.tintColor = .systemGreen
                firstTime = false
            }
        }, onNetworkAbsent: {
            DispatchQueue.main.async { [weak self] in
                if firstTime {
                    print("show saved posts")
                    self?.showSavedPosts()
                }
                button.tintColor = .systemYellow
                firstTime = false
            }
        })

        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.delegate = self
        view.addGestureRecognizer(swipeGesture)
    }

    // MARK: - Show posts

    private func getAndLoadPosts() {
        let savedPosts = MyFileManager.manager.savedPosts
        postsGetter.getRedditPosts(subreddit: subreddit, limit: limit, after: lastAfter) { [weak self] result in
            switch result {
            case .success(var posts):
                DispatchQueue.main.async {
                    posts = posts.map {
                        if savedPosts.contains($0) {
                            var newPost = $0
                            newPost.saved = true
                            return newPost
                        } else {
                            return $0
                        }
                    }

                    self?.posts.append(contentsOf: posts)
                    self?.tableView.reloadData()
                    self?.tableView.tableFooterView = nil
                }
            case .failure:
                break
            }
        }
    }

    @objc private func showSavedPosts() {
        showOnlySavedPosts = !showOnlySavedPosts
        if showOnlySavedPosts {
            posts = MyFileManager.manager.savedPosts
            tableView.reloadData()
        }

        searchBar.isHidden = !searchBar.isHidden

        if showOnlySavedPosts {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "bookmark.circle.fill"),
                style: .plain,
                target: self,
                action: #selector(showSavedPosts)
            )
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "bookmark.circle"),
                style: .plain,
                target: self,
                action: #selector(showSavedPosts)
            )
            searchBar.resignFirstResponder()
        }
    }

    // MARK: - Swipe and Spinner

    @objc private func handleSwipe(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began {
            _ = gestureRecognizer.translation(in: view)
            searchBar.resignFirstResponder()
        }
    }

    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))

        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()

        return footerView
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Const.segueIdentifier:
            let nextVc = segue.destination as! PostDetailsViewController
            nextVc.delegate = self
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.cellReuseIdentifier, for: indexPath) as! PostTableViewCell
        if !posts.isEmpty {
            cell.postViewDelegate = self
            cell.configure(with: posts[indexPath.row])
        }

        return cell
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if showOnlySavedPosts { return }

        let position = scrollView.contentOffset.y
        if position > tableView.contentSize.height - 100 - scrollView.frame.size.height {
            if !postsGetter.isPaginating {
                tableView.tableFooterView = createSpinnerFooter()
                getAndLoadPosts()
            }
        }
    }

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let savedPosts = MyFileManager.manager.savedPosts
        if searchText.isEmpty {
            posts = savedPosts
        } else {
            posts = savedPosts.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }

        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - PostViewDelegate

    func commentButtonTapped(in cell: PostView) {
        lastSelectedPost = cell.getPost
        performSegue(withIdentifier: Const.segueIdentifier, sender: self)
    }

    // MARK: - SelectedPostDelegate

    var post: Post? {
        lastSelectedPost
    }
}
