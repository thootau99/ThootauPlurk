//
//  NewPlurkView.swift
//  ThootauPlurk
//
//  Created by thootau on 2022/01/21.
//

import SwiftUI

struct NewPlurkView: View {
    @EnvironmentObject var Plurk: PlurkLibrary
    @State var plurkContent: String = ""
    var body: some View {
        VStack {
            HStack {
                TextField("Please input coneten of post", text: $plurkContent)
                Button("Send Plurk") {
                    Plurk.postPlurk(plurk_id: nil, content: plurkContent, qualifier: "").done({ result in
                        if result {
                            plurkContent = ""
                        }
                    })
                }
            }
        }
    }
}

struct NewPlurkView_Previews: PreviewProvider {
    static var previews: some View {
        NewPlurkView()
    }
}
