//
//  ContentView.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 18/10/20.
//

import SwiftUI
import SwifteriOS

struct ContentView: View {
    func signIn() {
        let swifter = Swifter(consumerKey: "", consumerSecret: "")

        swifter.authorize(
            withCallback: URL(string: "oltwitter://")!,
            presentingFrom: nil,
            success: { accessToken, response  in
                print("accessToken", accessToken)
                print("response", response)
            },
            failure: { error in
                print("error", error)
            }
        )
    }

    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()
            Button(action: signIn, label: {
                Text("Sign in with twitter")
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
