//
//  ThootauPlurkApp.swift
//  ThootauPlurk
//
//  Created by thootau on 2022/01/02.
//

import SwiftUI
import OAuthSwift

@main
struct ThootauPlurkApp: App {
    @ObservedObject var connector = WatchConnector()
    @ObservedObject var Plurk: PlurkLibrary = PlurkLibrary()
    var body: some Scene {
        WindowGroup {
            if (!Plurk.loginSuccess) {
                NotLoginView()
                    .environmentObject(Plurk)
                    .environmentObject(connector)
                    .onOpenURL(perform: {url in
                        OAuthSwift.handle(url: url)
                    })
            } else {
                NavigationView {
                    LoginedView()
                        .environmentObject(Plurk)
                        .environmentObject(connector)
                        .onOpenURL(perform: {url in
                            OAuthSwift.handle(url: url)
                        })
                }
            }
        }
    }
}
