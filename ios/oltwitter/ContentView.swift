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

    var body: some View {
        VStack {
            if (state.authUser != nil) {
                TimelineView()
            } else {
                if (state.authError != nil) {
                    Text("Error: " + (state.authError ?? ""))
                }
                Button(action: state.login, label: {
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
