//
//  PostViewController.swift
//  RedditApp
//
//  Created by Соня Буділова on 12.02.2024.
//

import SDWebImage
import SwiftUI
import UIKit

class PostDetailsViewController: UIViewController {
    @IBOutlet var postView: PostView!
    @IBOutlet var commentContainerView: UIView!
    var delegate: SelectedPostDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configure(with: delegate?.post)

        print(delegate?.post?.id ?? "")
        let swiftUIViewController: UIViewController = UIHostingController(rootView: CommentView(postId: delegate?.post?.id, subreddit: delegate?.post?.subreddit, navigationController: navigationController))
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

    func configure(with post: Post?) {
        if let post = post {
            postView.configure(with: post)
        }
    }
}

protocol SelectedPostDelegate {
    var post: Post? { get }
}
