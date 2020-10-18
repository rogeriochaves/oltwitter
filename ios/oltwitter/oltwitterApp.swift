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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { (url) in
                    let callbackUrl = URL(string: "oltwitter://")!
                    Swifter.handleOpenURL(url, callbackURL: callbackUrl)
                }
        }
    }
}
