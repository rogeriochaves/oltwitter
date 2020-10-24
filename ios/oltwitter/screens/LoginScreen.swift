//
//  LoginScreen.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 21/10/20.
//

import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject var state : AppState

    let white = Color(red: 1, green: 1, blue: 1)
    let blue = Color(red: 35 / 255, green: 176 / 255, blue: 230 / 255)

    var body: some View {
        ZStack {
            blue.ignoresSafeArea()
            VStack {
                VStack(alignment: .leading) {
                    Text("good ol'").font(.custom("American Typewriter", size: 25))
                        .padding(.leading, 20)
                    Text("twitter").font(.custom("American Typewriter", size: 90))
                        .padding(.top, -30)
                }.foregroundColor(white)
                if (state.authError != nil) {
                    Text("Error: " + (state.authError ?? ""))
                }
                Button(action: state.login, label: {
                    HStack {
                        Image("twitterlogo")
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 32, height: 25)
                        Text("Sign in with Twitter")
                    }
                        .foregroundColor(blue)
                        .padding(.horizontal, 60)
                        .padding(.vertical, 20)
                        .background(white)
                        .cornerRadius(50)
                }).padding(.top, 50)
            }
        }
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
            .environmentObject(AppState())
    }
}
