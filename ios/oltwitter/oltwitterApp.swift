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
                    case .background:
                        state.fetchNewTweets()
                    default:
                        break
                    }
                })
        }
    }
}
