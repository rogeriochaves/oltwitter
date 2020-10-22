//
//  AccountScreen.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 21/10/20.
//

import SwiftUI

struct AccountScreen: View {
    @EnvironmentObject var state : AppState

    func profile(_ user: AuthUser) -> some View {
        switch state.users[user.screenName] {
        case .success(let user):
            if let name = user["name"].string,
               let followers = user["followers_count"].integer,
               let following = user["friends_count"].integer,
               let tweets = user["statuses_count"].integer,
               let avatarUrl = user["profile_image_url_https"].string {
                return AnyView(Group {
                    NavigationLink(destination: TimelineScreen()) {
                        HStack {
                            AsyncImage(url: avatarUrl, imageLoader: state.imageLoader)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 48, height: 48)
                            VStack(alignment: .leading) {
                                Text(name).font(.title2)
                                Text("View your profile").font(.subheadline).foregroundColor(.gray)
                            }
                        }.padding(.vertical, 10)
                    }
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
                })
            }
        default:
            break
        }
        return AnyView(Group {
            HStack {
                Image("egg-avatar")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                VStack(alignment: .leading) {
                    Text(user.screenName).font(.title2)
                    Text("View your profile").font(.subheadline).foregroundColor(.gray)
                }
            }.padding(.vertical, 10)
            HStack {
                VStack {
                    Text(" ").font(.title).bold()
                    Text("tweets").font(.caption)
                }
                Spacer()
                VStack {
                    Text(" ").font(.title).bold()
                    Text("followers").font(.caption)
                }
                Spacer()
                VStack {
                    Text(" ").font(.title).bold()
                    Text("following").font(.caption)
                }
            }
        })
    }

    var body: some View {
        if let user = state.authUser {
            Form {
                Section(header: Text("Profile")) {
                    profile(user)
                }
                Section {
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("Sign out").foregroundColor(.red)
                    })
                }.onAppear() {
                    if let user = state.authUser {
                        state.fetchUser(screenName: user.screenName)
                    }
                }
            }
            .navigationBarTitle(user.screenName, displayMode: .inline)
        }
    }
}

struct AccountScreen_Previews: PreviewProvider {
    static var previews: some View {
        let user = AuthUser(
            twitterKey: "",
            twitterSecret: "",
            screenName: "john_doe",
            userId: ""
        )
        let state = AppState()
        state.authUser = user
        state.users[user.screenName] = .success(Utils.userSample())

        let stateLoading = AppState()
        stateLoading.authUser = user

        return Group {
            AccountScreen().environmentObject(state)
            AccountScreen().environmentObject(stateLoading)
        }
    }
}
