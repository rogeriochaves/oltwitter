//
//  ContentView.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 18/10/20.
//

import SwiftUI

struct ContentView: View {
    func signIn() {

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
