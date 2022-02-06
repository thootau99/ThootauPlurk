//
//  ThootauPlurkApp.swift
//  ThootauPlurk
//
//  Created by thootau on 2022/01/02.
//

import SwiftUI
import OAuthSwift
import UserNotifications
import BackgroundTasks

@main
struct ThootauPlurkApp: App {
    @Environment(\.scenePhase) var scenePhase
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
                        .onAppear(perform: {() in
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                if success {
                                    print("All set!")
                                } else if let error = error {
                                    print(error.localizedDescription)
                                }
                            }
                        })
                        .onOpenURL(perform: {url in
                            OAuthSwift.handle(url: url)
                        })
                }
            }
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase {
            case .background:
                print("in background")
            case .active:
                print("active")
            case .inactive:
                print("inactive")
            }
        
            
        }
    }
}
