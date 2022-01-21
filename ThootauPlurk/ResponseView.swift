//
//  ResponseView.swift
//  ThootauPlurk
//
//  Created by thootau on 2022/01/10.
//

import SwiftUI

struct ResponseBootomView: View {
    var plurk_id : Int
    @State var content: String = ""
    @EnvironmentObject var Plurk: PlurkLibrary
    var body: some View {
        HStack {
            TextField("enter response..", text: $content)
            Button("Send Plurk") {
                Plurk.postPlurk(plurk_id: plurk_id, content: content, qualifier: "").done({result in
                    if result {
                        content = ""
                    }
                })
            }
        }
    }
}

struct ResponseView: View {
    var plurk_id : Int
    @EnvironmentObject var Plurk: PlurkLibrary
    @State var originalPost: PlurkPost
    @State var response : GetResponse = GetResponse(responses: [], friends: [:])
    var body: some View {
        VStack {
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
            ResponseBootomView(plurk_id: plurk_id)
                .environmentObject(Plurk)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        
    }
}

