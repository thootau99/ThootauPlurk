//
//  RiverView.swift
//  ThootauPlurk
//
//  Created by thootau on 2022/01/02.
//

import SwiftUI

struct RiverView: View {
    @EnvironmentObject var Plurk: PlurkLibrary
    @State var plurks: GetPlurkResponse = GetPlurkResponse(plurks: [], plurk_users: [:])
    var body: some View {
        List {
            ForEach(self.plurks.plurks, id: \.self) { _plurk in
                PlurkPostView(post: _plurk)
                    .padding()
                    .overlay(Text(String(_plurk.response_count!)).offset(x: 0, y: -10), alignment: Alignment.topTrailing)
                    .environmentObject(Plurk)
            }
            Button("get more plurk") {
                Plurk.getPlurks(me: false).done { result in
                    self.plurks = result
                }
            }.onAppear(perform: { Plurk.getPlurks(me: false).done { result in
                self.plurks = result
            }
            })
            
        }
    }
}

struct RiverView_Previews: PreviewProvider {
    static var previews: some View {
        RiverView()
    }
}
