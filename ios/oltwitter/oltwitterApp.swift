//
//  oltwitterApp.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 18/10/20.
//

import SwiftUI
import SwifteriOS

@main
struct oltwitterApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var state = AppState()
    @State private var lastFetch = Date().currentTimeMillis()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(state)
                .onOpenURL { (url) in
                    let callbackUrl = URL(string: "oltwitter://")!
                    Swifter.handleOpenURL(url, callbackURL: callbackUrl)
                }
                .onChange(of: scenePhase, perform: { value in
                    switch scenePhase {
                    case .active:
                        let now = Date().currentTimeMillis()
                        let threeMinutes: Int64 = 1000 * 60 * 3;
                        if lastFetch > now - threeMinutes {
                            state.fetchNewTweets()
                            self.lastFetch = now
                        }
                    default:
                        break
                    }
                })
        }
    }
}
