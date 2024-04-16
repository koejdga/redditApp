//
//  PostTableViewCell.swift
//  RedditApp
//
//  Created by Соня Буділова on 16.02.2024.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    weak var postViewDelegate: PostViewDelegate?
    @IBOutlet private var postView: PostView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        postView.goToDefault()
    }

    func configure(with post: Post) {
        postView.delegate = postViewDelegate
        postView.configure(with: post)
    }
}
