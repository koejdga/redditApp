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
