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

    func fullText() -> String {
        var rt = ""
        if let rtScreenName = tweet["retweeted_status"]["user"]["screen_name"].string {
            rt = "RT @" + rtScreenName + " "
        }

        var text: String? = nil
        if let fullText = tweet["retweeted_status"]["extended_tweet"]["full_text"].string {
            text = rt + fullText
        }
        if text == nil,
           let fullText = tweet["retweeted_status"]["full_text"].string {
            text = rt + fullText
        }
        if text == nil,
           let fullText = tweet["extended_tweet"]["full_text"].string {
            text = fullText
        }
        if text == nil,
           let fullText = tweet["full_text"].string {
            text = fullText
        }
        if text == nil,
           let rtText = tweet["retweeted_status"]["text"].string {
            text = rt + rtText
        }
        if text == nil {
            text = tweet["text"].string
        }

        if let quotedText = tweet["quoted_status"]["full_text"].string,
           let quotedUserName = tweet["quoted_status"]["user"]["screen_name"].string,
           let quotedPermalink = tweet["quoted_status_permalink"]["url"].string {
            let quoted = "\n\nRT @\(quotedUserName) \(quotedText)"
            text = (text?.replacingOccurrences(of: quotedPermalink, with: "", options: .literal) ?? "") + quoted
        }

        if let inReplyTo = tweet["in_reply_to_screen_name"].string,
           let text_ = text,
           !text_.contains(inReplyTo) {
            text = "@\(inReplyTo) " + text_
        }

        text = text?.replacingOccurrences(of: "&amp;", with: "&")
        text = text?.replacingOccurrences(of: "&lt;", with: "<")
        text = text?.replacingOccurrences(of: "&gt;", with: ">")

        return text ?? ""
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                avatar().padding(.top, 4)
                VStack(alignment: .leading, spacing: 0) {
                    (
                        Text(tweet["user"]["name"].string ?? "")
                            .bold()
                        +
                        Text(" @" + (tweet["user"]["screen_name"].string ?? ""))
                            .foregroundColor(Styles.gray)
                    ).lineLimit(1).truncationMode(.tail)
                    LinkedText(fullText(), tweet)
                        .padding(.top, 5)
                }
            }.padding(.horizontal, 10)
            Divider()
        }.padding(.top, 10)
        .font(.system(size: Styles.tweetFontSize))
    }
}

struct TweetView_Previews: PreviewProvider {
    static var previews: some View {
        let state = AppState()
        let tweet = Utils.timelineSample()[1]

        return TweetView(tweet)
            .environmentObject(state)
    }
}
