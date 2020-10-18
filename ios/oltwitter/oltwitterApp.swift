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
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onOpenURL { (url) in
                    let callbackUrl = URL(string: "oltwitter://")!
                    Swifter.handleOpenURL(url, callbackURL: callbackUrl)
                }
        }
    }
}
