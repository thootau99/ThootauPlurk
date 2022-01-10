//
//  ResponseView.swift
//  ThootauPlurk
//
//  Created by thootau on 2022/01/10.
//

import SwiftUI

struct ResponseView: View {
    var plurk_id : Int
    @EnvironmentObject var Plurk: PlurkLibrary
    @State var originalPost: PlurkPost
    @State var response : GetResponse = GetResponse(responses: [], friends: [:])
    var body: some View {
        List {
            PlurkPostView(post: originalPost)
                .onAppear(perform: { Plurk.getPlurkResponses(plurk_id: plurk_id).done { result in
                    self.response = result
                }})
            ForEach(self.response.responses, id: \.self) { response in
                PlurkPostView(post: response)
                    .padding()
            }
        }
    }
}

