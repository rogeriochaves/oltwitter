//
//  TweetView.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 18/10/20.
//

import SwiftUI
import SwifteriOS

struct TweetView: View {
    @EnvironmentObject var state : AppState
    private let tweet:JSON

    init(_ tweet: JSON) {
        self.tweet = tweet
    }

    func avatar() -> some View {
        // TODO: get a better size avatar image
        let avatarUrl = tweet["user"]["profile_image_url_https"].string
        return AsyncImage(url: avatarUrl, imageLoader: state.imageLoader)
            .aspectRatio(contentMode: .fit)
            .frame(width: 48, height: 48)
    }

    var body: some View {
        VStack {
            HStack {
                avatar()
                VStack(alignment: .leading) {
                    HStack {
                        Text(tweet["user"]["name"].string ?? "")
                            .bold()
                        Text("@" + (tweet["user"]["screen_name"].string ?? ""))
                            .foregroundColor(Styles.gray)
                    }
                    Text(tweet["text"].string ?? "")
                }
            }.padding(.horizontal, 10)
            Divider()
        }
    }
}

struct TweetView_Previews: PreviewProvider {
    static var previews: some View {
        TweetView(Utils.timelineSample()[0])
    }
}
