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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
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
                let request = BGProcessingTaskRequest(identifier: "com.ThootauPlurk.refresh")
                    // 通信が発生するか否かを指定
                    request.requiresNetworkConnectivity = false
                    // CPU監視の必要可否を設定
                    request.requiresExternalPower = true

                    do {
                        // スケジューラーに実行リクエストを登録
                        try BGTaskScheduler.shared.submit(request)
                    } catch {
                        print("Could not schedule app processing: \(error)")
                    }

                print("in background")
            case .active:
                self.Plurk.getUserChannel().done {url in
                    appDelegate.channelURL = url
                }
                print("active")
            case .inactive:
                print("inactive")
            }
        }
    }
}
