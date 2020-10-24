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
        let screenName = user.screenName

        switch state.users[screenName] {
        case .success(let user):
            if let name = user["name"].string,
               let followers = user["followers_count"].integer,
               let following = user["friends_count"].integer,
               let tweets = user["statuses_count"].integer,
               let avatarUrl = user["profile_image_url_https"].string {
                return AnyView(Group {
                    NavigationLink(destination: ProfileScreen(screenName: screenName)) {
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
        ZStack {
            if let user = state.authUser {
                Form {
                    Section(header: Text("Profile")) {
                        profile(user)
                    }
                    Section {
                        Button(action: {
                            UIApplication.shared.open(URL(string: "https://github.com/rogeriochaves/oltwitter/")!, options: [:], completionHandler: nil)
                        }) {
                            Text("GitHub Repo")
                                .foregroundColor(Styles.linkBlue)
                        }
                        Button(action: {
                            UIApplication.shared.open(URL(string: "https://github.com/rogeriochaves/oltwitter/issues")!, options: [:], completionHandler: nil)
                        }) {
                            Text("Report an Issue")
                                .foregroundColor(Styles.linkBlue)
                        }
                        Button(action: state.logout) {
                            Text("Sign out").foregroundColor(.red)
                        }
                    }
                }
                .navigationBarTitle("Me", displayMode: .inline)
            }
        }.onAppear() {
            if let user = state.authUser {
                state.fetchUser(screenName: user.screenName)
            }
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
