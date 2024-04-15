//
//  SmallCommentView.swift
//  RedditApp
//
//  Created by Соня Буділова on 16.04.2024.
//

import SwiftUI

struct SmallCommentView: View {
    let comment: Comment
    @State private var showingAlert: Bool = false

    init(comment: Comment) {
        self.comment = comment
    }

    var body: some View {
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
                if let url = URL(string: comment.link) {
                    ShareLink("", item: url)
                } else {
                    Button(action: {
                        self.showingAlert = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Oops"), message: Text("The URL is not valid"), dismissButton: .default(Text("OK")))
                    }
                }
            }
        }
        .padding()

        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray, lineWidth: 1)
        )
        .padding(.horizontal, 10)
    }
}

#Preview {
    SmallCommentView(comment: Comment(author: "author", created: 100111010, body: "comment", ups: 3, downs: 1, id: "123", permalink: "12345"))
}
