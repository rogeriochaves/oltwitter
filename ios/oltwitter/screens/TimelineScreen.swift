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

enum ScrollPosition {
    case top
    case bottomWithNewTweets
    case bottom
}

struct TimelineScreen: View {
    @EnvironmentObject var state : AppState
    @State var timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    @State private var scrollPosition : ScrollPosition = .top
    @State var newTweetsVisible = 0
    private var hideTopBar : Bool

    init(hideTopBar: Bool = false) {
        self.hideTopBar = hideTopBar
    }

    func newTweetsButton() -> some View {
        if case .bottom = self.scrollPosition {
            return AnyView(EmptyView())
        }

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
                        // best I could find to read ScrollView position without affecting scroll view itself
                        // based on https://stackoverflow.com/a/64368200/996404
                        .background(GeometryReader { geo -> Text in
                            let posY = geo.frame(in: .global).minY

                            // displays new tweets only if scroll is already on top, or user scrolled top
                            // once when there were new tweets, so that we don't disrupt the scrolling when
                            // new tweets come in, triggering in the user the addiction to go to the top
                            // and check what's new constantly
                            if posY > -110 {
                                self.scrollPosition = .top
                            } else if case let .success(newTweets) = self.state.newTweets,
                                      case .top = self.scrollPosition,
                                      newTweets.count > 0 {
                                self.scrollPosition = .bottomWithNewTweets
                            } else {
                                self.scrollPosition = .bottom
                            }

                            return Text("")
                        })
                }
            case .loading:
                Text("Loading...")
            case let .error(message):
                Text("Error loading timeline: " + message)
            case .notAsked:
                EmptyView()
            }
            VStack {
                GeometryReader { geometry in
                    Styles.white
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Divider()
                    Spacer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(hideTopBar)
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
