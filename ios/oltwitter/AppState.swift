//
//  AppState.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 18/10/20.
//

import SwiftUI
import SwifteriOS

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

class AppState: ObservableObject {
    @Published var authUser : AuthUser?
    @Published var authError : String?

    init() {
        self.authUser = readAuthUser(key: "authUser")
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

    func fetchTweets() {
        if let client = getClient() {
            client.getHomeTimeline(count: 50, success: { json in
                print("json", json)
            }, failure: { error in
                print("error", error.localizedDescription)
            })
        }
    }
}
