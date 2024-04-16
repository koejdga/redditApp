//
//  PostViewController.swift
//  RedditApp
//
//  Created by Соня Буділова on 12.02.2024.
//

import SDWebImage
import SwiftUI
import UIKit

class PostDetailsViewController: UIViewController, CommentsDelegate {
    @IBOutlet private var postView: PostView!
    @IBOutlet private var commentContainerView: UIView!
    var delegate: SelectedPostDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configure(with: delegate?.post)

        print(delegate?.post?.id ?? "")

        let swiftUIViewController: UIViewController = UIHostingController(rootView: CommentsView(delegate: self, navigationController: navigationController))
        let swiftUIView: UIView = swiftUIViewController.view
        commentContainerView.addSubview(swiftUIView)

        swiftUIView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            swiftUIView.topAnchor.constraint(equalTo: commentContainerView.topAnchor),
            swiftUIView.trailingAnchor.constraint(equalTo: commentContainerView.trailingAnchor),
            swiftUIView.bottomAnchor.constraint(equalTo: commentContainerView.bottomAnchor),
            swiftUIView.leadingAnchor.constraint(equalTo: commentContainerView.leadingAnchor)
        ])

        swiftUIViewController.didMove(toParent: self)
    }

    private func configure(with post: Post?) {
        if let post = post {
            postView.configure(with: post)
        }
    }

    // MARK: - CommentsDelegate

    func fetchComments(completion: @escaping ([Comment]) -> Void) {
        CommentGetter().getRedditComments(subreddit: delegate?.post?.subreddit, postId: delegate?.post?.id) { result in
            switch result {
            case .success(let comments):
                completion(comments.sorted { $0.timePassed < $1.timePassed })
            case .failure:
                print("ERROR: Unable to fetch comments")
                completion([])
            }
        }
    }
}

protocol SelectedPostDelegate {
    var post: Post? { get }
}
