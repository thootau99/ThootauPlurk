//
//  AppDelegate.swift
//  ThootauPlurk
//
//  Created by thootau on 2022/02/06.
//
import UIKit
import BackgroundTasks

class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var channelURL: URL? = nil
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.ThootauPlurk.refresh", using: nil) { task in
            let userChannel:UserChannelRequest = UserChannelRequest()
            if let userChannelURL = self.channelURL {
                userChannel.start(execute_url: userChannelURL)
            }
        }
        return true
    }
}
