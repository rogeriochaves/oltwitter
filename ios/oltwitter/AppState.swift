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
        UserDefaults.standard.setNilValueForKey(key)
    }
}

class AppState: ObservableObject {
    @Published var authUser : AuthUser?

    init() {
        self.authUser = readAuthUser(key: "authUser")
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
}
