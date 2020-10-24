//
//  NewTweetScreen.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 24/10/20.
//

import SwiftUI

struct NewTweetScreen: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var state : AppState
    @State var text: String = ""
    @State var loading = false

    var body: some View {
        let remainingCharacters = 140 - text.count
        let overLimit = remainingCharacters < 0

        return ZStack(alignment: .bottomTrailing) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .padding()
                if text.isEmpty {
                    Text("What's happening?")
                        .foregroundColor(.gray)
                        .padding()
                        .padding(.top, 10)
                        .padding(.leading, 5)
                }
            }
            Text("\(remainingCharacters)")
                .bold()
                .font(.system(size: 40))
                .foregroundColor(.gray)
                .padding()
        }
        .navigationBarTitle("New tweet", displayMode: .inline)
        .navigationBarItems(
            trailing:
                Button(action: {
                    state.tweet(text: text, success: {
                        self.presentationMode.wrappedValue.dismiss()
                    })
                }) {
                    Text(loading ? "Tweeting..." : "Tweet")
                }
                .disabled(overLimit || loading)
                .foregroundColor((overLimit || loading) ? .gray : Color(UIColor.label))
        )
    }
}

struct NewTweetScreen_Previews: PreviewProvider {
    static var previews: some View {
        NewTweetScreen()
            .environmentObject(AppState())
    }
}
