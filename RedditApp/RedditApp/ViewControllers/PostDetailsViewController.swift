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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func configure(with post: Post) {
        postView.configure(with: post)
    }
}
