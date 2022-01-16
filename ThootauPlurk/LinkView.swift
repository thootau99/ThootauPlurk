//
//  LinkView.swift
//  ThootauPlurk
//
//  Created by thootau on 2022/01/16.
//

import SwiftUI

struct LinkView: View {
    var post: ParsedPost
    var body: some View {
        HStack {
            Label(title: { Text(post.content ?? "") }, icon: {
                AsyncImage(url: URL(string: post.thumbnails ?? "https://www.plurk.com/static/default_small.jpg")) {phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .onTapGesture {
                                print("touching \(String(describing: post.thumbnails))")
                            }
                    case .failure(_):
                        Image(systemName: "exclamationmark.icloud")
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(0.90, contentMode: .fill)
                    @unknown default:
                        Image(systemName: "exclamationmark.icloud")
                    }
                }
                .frame(minWidth: 24, maxWidth: 24, minHeight: 24, maxHeight: 24, alignment: .leading)
            })
        }
        .background(Color.cyan)
    }
}
//
//struct LinkView_Previews: PreviewProvider {
//    static var previews: some View {
//        LinkView()
//    }
//}
