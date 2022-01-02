//
//  ThootauPlurkApp.swift
//  ThootauPlurk WatchKit Extension
//
//  Created by thootau on 2022/01/02.
//

import SwiftUI

@main
struct ThootauPlurkApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
