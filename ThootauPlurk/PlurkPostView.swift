import SwiftUI


struct PlurkPostView : View {
    var post : PlurkPost
    @State private var imageTag: String?
    @State private var imageURL: String? = ""
    @EnvironmentObject var Plurk: PlurkLibrary

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
                VStack(alignment: HorizontalAlignment.leading) {
                    ForEach(post.contentParsed, id: \.self) { content in
                        switch content.tag {
                        case "a":
                            LinkView(post: content)
                        case "span":
                            if let content = content.content {
                                Text(content)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        case "br":
                            Text("\n")
                                .fixedSize(horizontal: false, vertical: true)
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
                                            .fixedSize(horizontal: false, vertical: true)
                                            .onTapGesture {
                                                self.imageURL = url.absoluteString.replacingOccurrences(of: "mx_", with: "")
                                                self.imageTag = "\(post.plurk_id)_photo"
                                                print("touching \(self.imageURL)")
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
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                NavigationLink(destination:
                                ResponseView(plurk_id: post.plurk_id!, originalPost: post)
                                    .environmentObject(Plurk)
                ) {
                    EmptyView()
                }.opacity(0)
                NavigationLink(tag: "\(String(describing: post.plurk_id))_photo", selection: self.$imageTag) {
                    ImageView(imageURL: URL(string: self.imageURL ?? ""))
                                                   } label: {
                                                       EmptyView()
                                                   }
                                                   .hidden()
            }
        }
        .frame(maxWidth: .infinity)
    }
}
