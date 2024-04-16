//
//  ContentView.swift
//  RedditAppSwiftUI
//
//  Created by Соня Буділова on 18.03.2024.
//

import SwiftUI

struct CommentsView: View {
    private var delegate: CommentsDelegate?
    @State private var comments: [Comment] = []
    private weak var navigationController: UINavigationController?

    init(delegate: CommentsDelegate? = nil, navigationController: UINavigationController? = nil) {
        self.delegate = delegate
        self.navigationController = navigationController
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Comments")
                .font(.title3)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
                .background(Color.ui.grey)

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(comments, id: \.id) { comment in
                        Button(
                            action: {
                                let swiftUIViewController = UIHostingController(rootView: WholeScreenCommentView(comment: comment))
                                self.navigationController?.pushViewController(swiftUIViewController, animated: true)
                            }
                        ) {
                            SmallCommentView(comment: comment)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    Spacer()
                }
                .padding(.top, 10)
            }
        }
        .onAppear {
            delegate?.fetchComments { result in
                comments = result
            }
        }
    }
}

protocol CommentsDelegate {
    func fetchComments(completion: @escaping ([Comment]) -> Void)
}

#Preview {
    CommentsView()
}
