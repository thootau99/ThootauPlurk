//
//  ThootauPlurkApp.swift
//  ThootauPlurk WatchKit Extension
//
//  Created by thootau on 2022/01/02.
//

import SwiftUI

@main
struct ThootauPlurkApp: App {
    @ObservedObject var connector = PhoneConnector()
    @ObservedObject var Plurk = PlurkLibrary()
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                if (connector.oauthToken.isEmpty && connector.oauthTokenSecret.isEmpty) {
                    NotLoginView()
                } else {
                    RiverView()
                        .environmentObject(connector)
                        .environmentObject(Plurk)
                        .onAppear(perform: {() in
                            Plurk._OAuthSwift.client.credential.oauthToken = connector.oauthToken
                            Plurk._OAuthSwift.client.credential.oauthTokenSecret = connector.oauthTokenSecret
                        })
                }
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
