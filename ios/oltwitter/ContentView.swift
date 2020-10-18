//
//  ContentView.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 18/10/20.
//

import SwiftUI
import SwifteriOS

struct ContentView: View {
    @EnvironmentObject var appState : AppState
    @State var authError : String? = nil

    func signIn() {
        let swifter = Swifter(consumerKey: "", consumerSecret: "")

        swifter.authorize(
            withCallback: URL(string: "oltwitter://")!,
            presentingFrom: nil,
            success: { accessToken, response in
                if let access = accessToken {
                    appState.saveLogin(accessToken: access)
                } else {
                    print("error", response)
                    authError = response.debugDescription
                }
            },
            failure: { error in
                print("error", error)
                authError = error.localizedDescription
            }
        )
    }

    var body: some View {
        VStack {
            if (appState.authUser != nil) {
                Text(appState.authUser?.screenName ?? "unknown")
                Button(action: appState.logout, label: {
                    Text("Sign out")
                })
            } else {
                if (authError != nil) {
                    Text("Error: " + (authError ?? ""))
                }
                Button(action: signIn, label: {
                    Text("Sign in with twitter")
                })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
