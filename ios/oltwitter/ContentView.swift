//
//  ContentView.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 18/10/20.
//

import SwiftUI
import SwifteriOS

struct ContentView: View {
    @EnvironmentObject var state : AppState

    init() {
        UITabBar.appearance().backgroundColor = UIColor.label
        UITabBar.appearance().barTintColor = UIColor.label
        UINavigationBar.appearance().barTintColor = UIColor(red: 68 / 255, green: 150 / 255, blue: 208 / 255, alpha: 1)
    }

    var body: some View {
        VStack {
            if (state.authUser == nil) {
                LoginScreen()
            } else {
                TabView {
                    NavigationView {
                        TimelineScreen()
                    }
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }

                    NavigationView {
                        AccountScreen()
                    }
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Me")
                    }
                }.accentColor(Styles.lightBlue)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let user = AuthUser(
            twitterKey: "",
            twitterSecret: "",
            screenName: "john doe",
            userId: ""
        )
        let state = AppState()
        state.authUser = user
        state.timeline = .success(Utils.timelineSample())

        return ContentView().environmentObject(state)
    }
}
