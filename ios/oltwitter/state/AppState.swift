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
    @Published var users : [String: ServerData<JSON>] = [:]
    @Published var userTimelines : [String: ServerData<[JSON]>] = [:]
    var firstTweetId : Int? = nil
    var lastTweetId : Int? = nil
    var imageLoader : ImageLoader
    var lastFetch = Date().currentTimeMillis()

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

    func initialTimelineFetch(force : Bool = false) {
        if case .loading = self.timeline {
            return
        }
        if case .notAsked = self.timeline {
            self.timeline = .loading
        } else if case .error(_) = self.timeline {
            self.timeline = .loading
        } else if (!force) {
            return
        }
        if let client = getClient() {
            client.getHomeTimeline(count: 50, tweetMode: .extended, success: { json in
                self.newTweets = .notAsked
                if let timeline = json.array {
                    self.timeline = .success(timeline)
                    self.firstTweetId = timeline.first?["id"].integer
                    self.lastTweetId = timeline.last?["id"].integer
                } else {
                    self.timeline = .error("Error parsing API data")
                }
            }, failure: { error in
                print("error", error.localizedDescription)
                if error.localizedDescription.contains("Too Many Requests") {
                    self.timeline = .error("Twitter API Limit: Too Many Requests")
                } else {
                    self.timeline = .error(error.localizedDescription)
                }
            })
        }
    }

    func fetchNewTweets() {
        let now = Date().currentTimeMillis()
        let threeMinutes: Int64 = 1000 * 60 * 1;
        if now - lastFetch < threeMinutes {
            return
        }

        if let client = getClient(),
           let firstTweetId = self.firstTweetId {
            self.lastFetch = now
            client.getHomeTimeline(count: 50, sinceID: String(firstTweetId), tweetMode: .extended, success: { json in
                if var newTweets = json.array {
                    newTweets = newTweets.filter { tweet in
                        tweet["id"].integer != self.firstTweetId
                    }
                    self.newTweets = .success(newTweets)
                }
            }, failure: { error in
                print("error", error.localizedDescription)
            })
        }
    }

    func fetchMoreTweets() {
        if case let .success(newTweets) = self.newTweets, newTweets.count > 45 {
            return
        }

        if let client = getClient(),
           case let .success(timeline) = self.timeline,
           let lastTweetId = self.lastTweetId {
            self.moreTweets = .loading
            client.getHomeTimeline(count: 50, maxID: String(lastTweetId), tweetMode: .extended, success: { json in
                if var moreTweets = json.array {
                    moreTweets = moreTweets.filter { tweet in
                        tweet["id"].integer != self.lastTweetId
                    }
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
                if error.localizedDescription.contains("Too Many Requests") {
                    self.moreTweets = .error("Twitter API Limit: Too Many Requests")
                } else {
                    self.moreTweets = .error(error.localizedDescription)
                }
            })
        }
    }

    func showNewTweets() {
        if case let .success(newTweets) = self.newTweets,
           case let .success(timeline) = self.timeline {
            if newTweets.count > 45 {
                self.newTweets = .loading
                initialTimelineFetch(force: true)
            } else {
                self.timeline = .success(newTweets + timeline)
                self.newTweets = .notAsked
                self.firstTweetId = newTweets.first?["id"].integer
            }
        }
    }

    func fetchUserTimeline(screenName : String) {
        if let client = getClient() {
            if userTimelines[screenName] == nil {
                userTimelines[screenName] = .loading
            }
            client.getTimeline(for: .screenName(screenName), tweetMode: .extended, success: { json in
                if let timeline = json.array {
                    self.userTimelines[screenName] = .success(timeline)
                } else {
                    self.userTimelines[screenName] = .error("Error parsing API data")
                }
            }, failure: { error in
                print("error", error.localizedDescription)
                if case .loading = self.userTimelines[screenName] {
                    self.userTimelines[screenName] = .error(error.localizedDescription)
                }
            })
        }
    }

    func fetchUser(screenName : String) {
        if let client = getClient(), users[screenName] == nil {
            users[screenName] = .loading
            client.showUser(.screenName(screenName), success: { json in
                self.users[screenName] = .success(json)
            }, failure: { error in
                print("error", error.localizedDescription)
                if case .loading = self.users[screenName] {
                    self.users[screenName] = .error(error.localizedDescription)
                }
            })
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
        UserDefaults.standard.removeObject(forKey: key)
    }
}
