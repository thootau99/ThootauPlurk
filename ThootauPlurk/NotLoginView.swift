//
//  ContentView.swift
//  ThootauPlurk
//
//  Created by thootau on 2022/01/02.
//

import SwiftUI

struct NotLoginView: View {
    @EnvironmentObject var Plurk: PlurkLibrary
    @EnvironmentObject var connector: WatchConnector
    var body: some View {
        Button("Login") {
             Plurk.login() {
                 var tokens : Array<Message> = []
                 let token: Message = Message(key: "oauthToken", value: "\(self.Plurk._OAuthSwift.client.credential.oauthToken),\(self.Plurk._OAuthSwift.client.credential.oauthTokenSecret)")
                tokens.append(token)
                self.connector.send(messages: tokens)
        }
    }
        Button("Logout") {
             Plurk.logout()
        }
    }
}

struct NotLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NotLoginView()
    }
}
