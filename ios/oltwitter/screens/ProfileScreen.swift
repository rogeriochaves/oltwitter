//
//  ProfileScreen.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 22/10/20.
//

import SwiftUI
import SwifteriOS

struct ProfileScreen: View {
    @EnvironmentObject var state : AppState
    var screenName : String

    init(screenName : String) {
        self.screenName = screenName
    }

    func profile(_ user: JSON) -> some View {
        if let name = user["name"].string,
           let followers = user["followers_count"].integer,
           let following = user["friends_count"].integer,
           let tweets = user["statuses_count"].integer,
           let avatarUrl = user["profile_image_url_https"].string {
            return AnyView(Group {
                HStack {
                    AsyncImage(url: avatarUrl, imageLoader: state.imageLoader)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                    VStack(alignment: .leading) {
                        Text(name).font(.title)
                        Text("@\(screenName)").font(.headline).foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                HStack {
                    VStack {
                        Text("\(tweets)").font(.title2).bold()
                        Text("tweets").font(.caption)
                    }
                    Spacer()
                    VStack {
                        Text("\(followers)").font(.title2).bold()
                        Text("followers").font(.caption)
                    }
                    Spacer()
                    VStack {
                        Text("\(following)").font(.title2).bold()
                        Text("following").font(.caption)
                    }
                }
                .padding(.horizontal, 50)
                Divider()
            })
        }
        return AnyView(EmptyView())
    }

    func tweets(_ tweets: [JSON]) -> some View {
        let tweets = tweets.map { tweet in
            IdentifiableJson(id: tweet["id"].integer ?? 0, value: tweet)
        }

        return VStack(alignment: .leading, spacing: 0) {
            ForEach(tweets) { tweet in
                TweetView(tweet.value)
            }
        }
    }

    var body: some View {
        ZStack {
            if case let .success(user) = state.users[screenName],
                case let .success(timeline) = state.userTimelines[screenName]
               {
                ScrollView {
                    profile(user)
                    tweets(timeline)
                }
            } else if case let .error(message) = state.users[screenName] {
                Text(message)
            } else if case let .error(message) = state.userTimelines[screenName] {
                Text(message)
            } else {
                Text("Loading...")
            }
        }
        .navigationBarTitle("@\(screenName)", displayMode: .inline)
        .onAppear() {
            state.fetchUser(screenName: screenName)
            state.fetchUserTimeline(screenName: screenName)
        }
    }
}

struct ProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        let user = AuthUser(
            twitterKey: "",
            twitterSecret: "",
            screenName: "_rchaves_",
            userId: ""
        )
        let state = AppState()
        state.users[user.screenName] = .success(Utils.userSample())
        state.userTimelines[user.screenName] = .success(Utils.timelineSample())

        let stateLoading = AppState()

        return Group {
            ProfileScreen(screenName: "_rchaves_").environmentObject(state)
            ProfileScreen(screenName: "_rchaves_").environmentObject(stateLoading)
        }
    }
}

