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

struct TimelineScreen: View {
    @EnvironmentObject var state : AppState
    @State var timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    func newTweetsButton() -> some View {
        switch state.newTweets {
        case let .success(newTweets):
            if newTweets.count > 45 {
                return AnyView(
                    moreButton(action: state.showNewTweets, label: "50+ new tweets")
                )
            } else if newTweets.count > 0 {
                return AnyView(
                    moreButton(action: state.showNewTweets, label: "\(newTweets.count) new tweets")
                )
            }
            return AnyView(EmptyView())
        case .loading:
            return AnyView(
                moreButton(action: {}, label: "loading...")
            )
        default:
            return AnyView(EmptyView())
        }
    }

    func moreTweetsButton() -> some View {
        switch state.moreTweets {
        case .notAsked:
            return AnyView(
                moreButton(action: state.fetchMoreTweets, label: "more")
            )
        case .loading:
            return AnyView(
                moreButton(action: {}, label: "loading...")
            )
        case .error(let err):
            return AnyView(VStack {
                Text(err)
                moreButton(action: state.fetchMoreTweets, label: "more")
            })
        default:
            return AnyView(EmptyView())
        }
    }

    func moreButton(action: @escaping () -> Void, label: String) -> some View {
        Button(action: action, label: {
            Text(label)
            .frame(height: 40, alignment: .center)
            .frame(maxWidth: .infinity)
            .foregroundColor(Styles.blueText)
            .background(Styles.lightestBlue)
            .border(Styles.lightBlue)
        })
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
    }

    func tweets(_ tweets: [JSON]) -> some View {
        let tweets = tweets.map { tweet in
            IdentifiableJson(id: tweet["id"].integer ?? 0, value: tweet)
        }

        return VStack(alignment: .leading, spacing: 0) {
            newTweetsButton()
            ForEach(tweets) { tweet in
                TweetView(tweet.value)
            }
            moreTweetsButton()
        }
    }

    var body: some View {
        ZStack {
            switch state.timeline {
            case let .success(timeline):
                ScrollView {
                    tweets(timeline)
                }
            case .loading:
                Text("Loading...")
            case let .error(message):
                Text("Error loading timeline: " + message)
            case .notAsked:
                EmptyView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Image("inset-twitter-logo")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 29, height: 24)
                }
            }
        }
        .onAppear() {
            state.initialTimelineFetch()
        }
        .onReceive(self.timer) { (_) in
            state.fetchNewTweets()
        }
    }
}

struct TimelineScreen_Previews: PreviewProvider {
    static var previews: some View {
        let state = AppState()
        state.timeline = .success(Utils.timelineSample())
        state.newTweets = .success(Utils.timelineSample().dropLast(40))

        let loadingState = AppState()
        loadingState.timeline = .loading

        return Group {
            TimelineScreen().environmentObject(state)
            TimelineScreen().environmentObject(loadingState)
        }
    }
}
