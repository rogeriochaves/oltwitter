//
//  AppState.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 18/10/20.
//

import SwiftUI
import SwifteriOS

class AppState: ObservableObject {
    @Published var authUser : AuthUser?
    @Published var authError : String?
    @Published var timeline : ServerData<[JSON]> = .notAsked
    @Published var newTweets : ServerData<[JSON]> = .notAsked
    @Published var moreTweets : ServerData<[JSON]> = .notAsked
    var firstTweetId : Int? = nil
    var lastTweetId : Int? = nil
    var imageLoader : ImageLoader

    init() {
        self.authUser = readAuthUser(key: "authUser")
        self.imageLoader = ImageLoader()
    }

    func login() {
        let swifter = Swifter(
            consumerKey: Utils.envVar("TWITTER_CONSUMER_KEY")!,
            consumerSecret: Utils.envVar("TWITTER_CONSUMER_SECRET")!
        )

        swifter.authorize(
            withCallback: URL(string: "oltwitter://")!,
            presentingFrom: nil,
            success: { accessToken, response in
                if let access = accessToken {
                    self.saveLogin(accessToken: access)
                } else {
                    print("error", response)
                    self.authError = response.debugDescription
                }
            },
            failure: { error in
                print("error", error)
                self.authError = error.localizedDescription
            }
        )
    }

    func saveLogin(accessToken: Credential.OAuthAccessToken) {
        let user = AuthUser(
            twitterKey: accessToken.key,
            twitterSecret: accessToken.secret,
            screenName: accessToken.screenName ?? "unknown",
            userId: accessToken.userID ?? "0"
        )
        saveAuthUser(key: "authUser", authUser: user)
        self.authUser = user
    }

    func logout() {
        saveAuthUser(key: "authUser", authUser: nil)
        self.authUser = nil
    }

    func getClient() -> Swifter? {
        if let user = authUser {
            return Swifter(
                consumerKey: Utils.envVar("TWITTER_CONSUMER_KEY")!,
                consumerSecret: Utils.envVar("TWITTER_CONSUMER_SECRET")!,
                oauthToken: user.twitterKey,
                oauthTokenSecret: user.twitterSecret
            )
        }
        return nil
    }

    // TODO offsets
    func initialTimelineFetch() {
        if case .notAsked = self.timeline, let client = getClient() {
            self.timeline = .loading

            client.getHomeTimeline(count: 50, tweetMode: .extended, success: { json in
                if let timeline = json.array {
                    self.timeline = .success(timeline)
                    self.firstTweetId = timeline.first?["id"].integer
                    self.lastTweetId = timeline.last?["id"].integer
                } else {
                    self.timeline = .error("Error parsing API data")
                }
            }, failure: { error in
                print("error", error.localizedDescription)
                self.timeline = .error(error.localizedDescription)
            })
        } else if case .loading = self.timeline {
            // nothing
        }
    }

    func fetchNewTweets() {
        if let client = getClient(),
           let firstTweetId = self.firstTweetId {
            client.getHomeTimeline(count: 50, sinceID: String(firstTweetId), tweetMode: .extended, success: { json in
                if let newTweets = json.array {
                    self.newTweets = .success(newTweets)
                    if newTweets.count > 0 {
                        self.firstTweetId = newTweets.first?["id"].integer
                    }
                } else {
                    self.newTweets = .error("Error parsing API data")
                }
            }, failure: { error in
                print("error", error.localizedDescription)
                self.newTweets = .error(error.localizedDescription)
            })
        }
    }

    func fetchMoreTweets() {
        if let client = getClient(),
           case let .success(timeline) = self.timeline,
           let lastTweetId = self.lastTweetId {
            self.moreTweets = .loading
            client.getHomeTimeline(count: 50, maxID: String(lastTweetId), tweetMode: .extended, success: { json in
                if let moreTweets = json.array {
                    self.moreTweets = .notAsked
                    if moreTweets.count > 0 {
                        self.timeline = .success(timeline + moreTweets)
                        self.lastTweetId = moreTweets.last?["id"].integer
                    } else {
                        self.moreTweets = .error("No more tweets")
                    }
                } else {
                    self.moreTweets = .error("Error parsing API data")
                }
            }, failure: { error in
                print("error", error.localizedDescription)
                self.moreTweets = .error(error.localizedDescription)
            })
        }
    }

    func showNewTweets() {
        if case let .success(newTweets) = self.newTweets,
           case let .success(timeline) = self.timeline {
            self.timeline = .success(newTweets + timeline)
            self.newTweets = .notAsked
        }
    }
}

struct AuthUser : Codable {
    var twitterKey: String
    var twitterSecret : String
    var screenName : String
    var userId : String
}

func readAuthUser(key: String) -> AuthUser? {
    if let data = UserDefaults.standard.object(forKey: key) as? Data {
        return try? JSONDecoder().decode(AuthUser.self, from: data)
    }
    return nil
}

func saveAuthUser(key: String, authUser: AuthUser?) {
    if let newValue = authUser {
        if let encoded = try? JSONEncoder().encode(newValue) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    } else {
        UserDefaults.standard.set(nil, forKey: key)
    }
}
