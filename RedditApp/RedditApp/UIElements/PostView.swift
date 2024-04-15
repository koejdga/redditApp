//
//  PostView.swift
//  RedditApp
//
//  Created by Соня Буділова on 16.02.2024.
//

import UIKit

class PostView: UIView {
    // MARK: - IBOutlets

    let kCONTENT_XIB_NAME = "PostView"
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var usernameLabel: UILabel!
    @IBOutlet private var timePassedLabel: UILabel!
    @IBOutlet private var domainLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var ratingLabel: UILabel!
    @IBOutlet private var commentsButton: UIButton!
    @IBOutlet private var previewImage: UIImageView!
    @IBOutlet private var saveButton: UIButton!
    @IBOutlet private var bookmarkView: UIView!
    @IBOutlet private var parentViewController: UIViewController?

    // MARK: - IBActions

    @IBAction func commentButtonTapped(_ sender: UIButton) {
        delegate?.commentButtonTapped(in: self)
    }

    @IBAction func saveOrUnsavePost(button: UIButton) {
        if var post = post {
            post.saved = !post.saved

            if post.saved {
                MyFileManager.manager.writeToFile(post: post)
            } else {
                MyFileManager.manager.removeFromFile(post: post)
            }

            let buttonImage = post.saved ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
            saveButton.setImage(buttonImage, for: .normal)

            self.post = post
        }
    }

    @IBAction func sharePost() {
        if let post = post, let url = URL(string: post.link) {
            print("INFO: Shared post")
            let items = [url]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            parentViewController?.present(ac, animated: true)
        }
    }

    // MARK: - Properties

    private var post: Post?
    weak var delegate: PostViewDelegate?
    public var getPost: Post? {
        post
    }

    // MARK: - Initialisation

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

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(tapGestureRecognizer)
    }

    override func draw(_ rect: CGRect) {
        super.draw(frame)
        drawBookmark(in: bookmarkView)
        bookmarkView.isHidden = true
    }

    // MARK: - Show Bookmark

    @objc func didTapView(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.bookmarkView.isHidden = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.transition(
                with: self,
                duration: 1,
                options: .transitionCrossDissolve
            ) { [weak self] in
                self?.bookmarkView.isHidden = true
            }
        }

        savePost()
    }

    func drawBookmark(in view: UIView) {
        view.backgroundColor = UIColor.clear

        view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let bookmarkPath = UIBezierPath()

        let bookmarkWidth: CGFloat = view.frame.width
        let bookmarkHeight: CGFloat = view.frame.height
        let xOffset: CGFloat = 0.0
        let yOffset: CGFloat = 0.0

        bookmarkPath.move(to: CGPoint(x: xOffset, y: yOffset))
        bookmarkPath.addLine(to: CGPoint(x: xOffset + bookmarkWidth, y: yOffset))
        bookmarkPath.addLine(to: CGPoint(x: xOffset + bookmarkWidth, y: yOffset + bookmarkHeight))
        bookmarkPath.addLine(to: CGPoint(x: xOffset + bookmarkWidth / 2, y: yOffset + bookmarkHeight * 0.6))
        bookmarkPath.addLine(to: CGPoint(x: xOffset, y: yOffset + bookmarkHeight))
        bookmarkPath.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bookmarkPath.cgPath
        shapeLayer.fillColor = UIColor.gray.cgColor

        view.layer.addSublayer(shapeLayer)
    }

    func savePost() {
        if var post = post {
            if post.saved { return }

            post.saved = true
            MyFileManager.manager.writeToFile(post: post)
            let buttonImage = UIImage(systemName: "bookmark.fill")
            saveButton.setImage(buttonImage, for: .normal)
            self.post = post
        }
    }

    // MARK: - Setup

    func configure(with post: Post) {
        usernameLabel.text = post.author_fullname ?? "unknown"
        timePassedLabel.text = post.timePassed
        domainLabel.text = post.domain
        titleLabel.text = post.title
        ratingLabel.text = String(post.rating)
        commentsButton.setTitle(" \(post.num_comments)", for: .normal)

        if let url = post.image_url {
            previewImage.sd_setImage(with: url)
        }

        let buttonImage = post.saved ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
        saveButton.setImage(buttonImage, for: .normal)

        self.post = post
    }

    func goToDefault() {
        usernameLabel.text = "username"
        timePassedLabel.text = "time passed"
        domainLabel.text = "domain"
        titleLabel.text = "Title"
        ratingLabel.text = "0"
        commentsButton.setTitle(" 0", for: .normal)
        previewImage.image = UIImage(named: "placeholder-image")
        saveButton.isSelected = false
        post = nil
    }
}

// MARK: - Other

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

protocol PostViewDelegate: AnyObject {
    func commentButtonTapped(in cell: PostView)
}
