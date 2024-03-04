//
//  PostViewController.swift
//  RedditApp
//
//  Created by Соня Буділова on 12.02.2024.
//

import SDWebImage
import UIKit

class PostDetailsViewController: UIViewController {
    @IBOutlet var postView: PostView!
    var post: Post?
    var delegate: SelectedPostDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configure(with: delegate?.post)
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
