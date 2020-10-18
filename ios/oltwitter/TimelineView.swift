//
//  TimelineView.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 18/10/20.
//

import SwiftUI
import SwifteriOS

struct IdentifiableJson : Identifiable {
    var id : Int
    var value : JSON
}

struct TimelineView: View {
    @EnvironmentObject var state : AppState

    func tweets(_ tweets: JSON) -> some View {
        let tweets = (tweets.array ?? []).map { tweet in
            IdentifiableJson(id: tweet["id"].integer ?? 0, value: tweet)
        }

        return VStack(alignment: .leading, spacing: 0) {
            ForEach(tweets) { tweet in
                TweetView(tweet.value)
            }
        }
    }

    var body: some View {
        ScrollView {
            switch state.timeline {
            case let .success(timeline):
                tweets(timeline)
            case .loading:
                Text("Loading...")
            case let .error(message):
                Text("Error loading timeline: " + message)
            case .notAsked:
                EmptyView()
            }
        }.onAppear() {
            state.fetchTweets()
        }
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        let state = AppState()
        state.timeline = .success(Utils.timelineSample())

        return TimelineView()
            .environmentObject(state)
    }
}
