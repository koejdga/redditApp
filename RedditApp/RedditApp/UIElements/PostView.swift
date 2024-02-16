//
//  PostView.swift
//  RedditApp
//
//  Created by Соня Буділова on 16.02.2024.
//

import UIKit

class PostView: UIView {
    let kCONTENT_XIB_NAME = "PostView"
    @IBOutlet var contentView: UIView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var timePassedLabel: UILabel!
    @IBOutlet var domainLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var commentsLabel: UILabel!
    @IBOutlet var previewImage: UIImageView!
    @IBOutlet var saveButton: UIButton!

    private var post: Post?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }

    func configure(with post: Post) {
        usernameLabel.text = post.author_fullname
        timePassedLabel.text = post.timePassed
        domainLabel.text = post.domain
        titleLabel.text = post.title
        ratingLabel.text = String(post.rating)
        commentsLabel.text = String(post.num_comments)

        if let url = post.image_url {
            previewImage.sd_setImage(with: url)
        }

        saveButton.isSelected = post.saved

        self.post = post
    }

    func goToDefault() {
        usernameLabel.text = "username"
        timePassedLabel.text = "time passed"
        domainLabel.text = "domain"
        titleLabel.text = "Title"
        ratingLabel.text = "0"
        commentsLabel.text = "0"
        previewImage.image = UIImage(contentsOfFile: "placeholder-image")
        saveButton.isSelected = false
        post = nil
    }

    @IBAction func savePost(button: UIButton) {
        print("savedPost")
        if var post = post {
            post.saved = !post.saved
            let buttonImage = post.saved ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
            saveButton.setImage(buttonImage, for: .normal)

            self.post = post
        }
    }
}

extension UIView {
    func fixInView(_ container: UIView!) {
        translatesAutoresizingMaskIntoConstraints = false
        frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
