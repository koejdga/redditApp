//
//  WholeScreenCommentView.swift
//  RedditApp
//
//  Created by Соня Буділова on 09.04.2024.
//

import Foundation
import SwiftUI

struct WholeScreenCommentView: View {
    private let comment: Comment

    init(comment: Comment) {
        self.comment = comment
    }

    var body: some View {
        VStack(spacing: 25) {
            HStack {
                Text("/u/\(comment.author)")
                Spacer()
                Text(comment.timePassed)
            }
            .padding(.bottom, 10)

            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray, lineWidth: 1)
                .fill(Color.ui.theme)
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
        if let url = URL(string: comment.link) {
            ShareLink("Share URL", item: url)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.ui.grey)
                .cornerRadius(6.0)
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
        } else {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.pink, lineWidth: 1)
                .overlay(
                    Text("Cannot share this comment :(")
                )
                .frame(height: 50)
                .padding(.horizontal, 10)
        }
    }
}

#Preview {
    WholeScreenCommentView(comment: Comment(author: "author", created: 100111010, body: "comment", ups: 3, downs: 1, id: "123", permalink: "12345"))
}
