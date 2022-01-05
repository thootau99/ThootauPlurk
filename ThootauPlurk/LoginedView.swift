//
//  LoginedView.swift
//  ThootauPlurk
//
//  Created by thootau on 2022/01/02.
//

import SwiftUI

struct LoginedView: View {
    @EnvironmentObject var Plurk: PlurkLibrary
    @EnvironmentObject var connector: WatchConnector
    var body: some View {
        TabView {
            RiverView()
                .tabItem {
                    Image(systemName: "tray.fill")
                    Text("Plurks")
                }
                .environmentObject(Plurk)
            Text("New Plurk")
                .tabItem {
                    Image(systemName: "pencil.circle")
                    Text("New Plurk")
                }
            Text("Personal")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Personal")
                }
            NotLoginView()
                .tabItem {
                    Image(systemName: "appleWatch")
                    Text("Watch Connector")
                }
                .environmentObject(Plurk)
                .environmentObject(connector)
        }
    }
}

struct LoginedView_Previews: PreviewProvider {
    static var previews: some View {
        LoginedView()
    }
}
