import SwiftUI


struct PlurkPostView : View {
    var post : PlurkPost
    var body: some View {
        ZStack {
            VStack(alignment: .leading ) {
                Label(title: { Text(post.display_name ?? "") }, icon: {
                    AsyncImage(url: URL(string: post.avatar_url ?? "https://www.plurk.com/static/default_small.jpg")) {phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .onTapGesture {
                                    print("touching \(post.avatar_url)")
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
                    
                    ForEach(post.contentParsed, id: \.self) { content in
                        switch content.tag {
                        case "a":
                            if let url = content.url, let title = content.content {
                                Link(title, destination: url)
                            }
                        case "span":
                            if let content = content.content {
                                Text(content)
                            }
                        case "br":
                            Text("\n")
                        case "img":
                            if let url = content.url {
                                AsyncImage(url: url) {phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .onTapGesture {
                                                print("touching \(url)")
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
                            }
                        default:
                            Text(content.content ?? "")
                        }
                    }
                 
            }
//            NavigationLink(destination: {
//                PlurkDetailView(plurk_id: post.plurk_id ?? 0).environmentObject(plurk) }) {
//                    EmptyView()
//                }.opacity(0)
//            NavigationLink(tag: "\(post.plurk_id)_photo", selection: $imageTag) {
//                ImageView(imageURL: imageURL ?? "")
//                                   } label: {
//                                       EmptyView()
//                                   }
//                                   .hidden()
            
        }

    }
    
}
