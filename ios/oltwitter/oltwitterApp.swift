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
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        }
    }
}

// From: https://stackoverflow.com/a/63942065/996404
extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // set to `false` if you don't want to detect tap during other gestures
    }
}
