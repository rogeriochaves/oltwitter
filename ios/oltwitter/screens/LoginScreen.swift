//
//  LoginScreen.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 21/10/20.
//

import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject var state : AppState

    var body: some View {
        VStack {
            if (state.authError != nil) {
                Text("Error: " + (state.authError ?? ""))
            }
            Button(action: state.login, label: {
                Text("Sign in with twitter")
            })
        }
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
