//
//  TimelineView.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 18/10/20.
//

import SwiftUI

struct TimelineView: View {
    @EnvironmentObject var state : AppState

    var body: some View {
        VStack {
            Text(state.authUser?.screenName ?? "unknown")
            Button(action: state.logout, label: {
                Text("Sign out")
            })
        }.onAppear() {
            state.fetchTweets()
        }
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
