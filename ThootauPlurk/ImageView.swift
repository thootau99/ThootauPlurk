//
//  ImageView.swift
//  ThootauPlurk
//
//  Created by thootau on 2022/01/15.
//

import SwiftUI

struct ImageView: View {
    var imageURL: URL?
    var body: some View {
        ZStack {
            AsyncImage(url: imageURL) {phase in
                        switch phase {
                        case .empty:
                            Color.purple.opacity(0.1)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure(_):
                            Image(systemName: "exclamationmark.icloud")
                                .resizable()
                                .scaledToFit()
                                .aspectRatio(0.90, contentMode: .fill)
                        @unknown default:
                            Image(systemName: "exclamationmark.icloud")
                        }
                    }
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(imageURL: URL(string: "http://placekitten.com/200/300")!)
    }
}
