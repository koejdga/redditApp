//
//  ContentView.swift
//  RedditAppSwiftUI
//
//  Created by Соня Буділова on 18.03.2024.
//

import SwiftUI

struct CommentView: View {
    let postId: String? // "1bi2gal"
    let subreddit: String? // "ios"

    @State private var comments: [Comment] = []

    weak var navigationController: UINavigationController?

    private func loadComments() {
//        TODO: make delegate for comment getter
        CommentGetter().getRedditComments(subreddit: subreddit, postId: postId) { result in
            switch result {
            case .success(let comments):
                self.comments = comments.sorted { $0.timePassed < $1.timePassed }
            case .failure:
                print("ERROR: Unable to fetch comments")
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Comments")
                .font(.title3)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
                .background(Color(.lightGray))

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(comments, id: \.id) { comment in
                        Button(
                            action: {
                                let swiftUIViewController = UIHostingController(rootView: WholeScreenCommentView(comment: comment))
                                self.navigationController?.pushViewController(swiftUIViewController, animated: true)
                            }
                        ) {
                            self.makeComment(comment)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    Spacer()
                }
                .onAppear {
                    loadComments()
                }
                .padding(.top, 10)
            }
        }
    }

    @ViewBuilder
    private func makeComment(_ comment: Comment) -> some View {
        VStack {
            HStack {
                Text("/u/\(comment.author)")
                Spacer()
                Text(comment.timePassed)
            }
            .padding(.bottom, 10)

            Text(comment.body)
                .padding(.bottom, 10)
                .font(.system(size: 20))

            HStack {
                Text("Rating: \(comment.rating)")
                Spacer()
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .padding()

        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray, lineWidth: 1)
        )
        .background(.white)
        .padding(.horizontal, 10)
    }

    @ViewBuilder
    public func makeWholeScreenComment(_ comment: Comment) -> some View {
        VStack(spacing: 25) {
            HStack {
                Text("/u/\(comment.author)")
                Spacer()
                Text(comment.timePassed)
            }
            .padding(.bottom, 10)

            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray, lineWidth: 1)
                .fill(Color("ThemeColor"))
                .frame(maxWidth: .infinity)
                .overlay(
                    Text(comment.body)
                        .font(.system(size: 20))
                        .padding()
                )

            HStack {
                Text("Rating: \(comment.rating)")
                Spacer()
            }
        }
        .padding()
        Spacer()
        ShareLink("Share URL", item: URL(string: comment.permalink)!)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color(.lightGray))
            .cornerRadius(6.0)
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
    }
}

#Preview {
    CommentView(postId: "1bi2gal", subreddit: "ios")
}
