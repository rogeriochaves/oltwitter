module ApplicationHelper
  def full_text(tweet)
    rt = "RT @#{tweet["retweeted_status"]["user"]["screen_name"]} " if tweet["retweeted_status"]

    text = nil
    text = rt + tweet["retweeted_status"]["extended_tweet"]["full_text"] if tweet["retweeted_status"] and tweet["retweeted_status"]["extended_tweet"]
    text = rt + tweet["retweeted_status"]["full_text"] if not text and tweet["retweeted_status"]
    text = tweet["extended_tweet"]["full_text"] if not text and tweet["extended_tweet"]
    text = tweet["full_text"] if not text and tweet["full_text"]
    text = rt + tweet["retweeted_status"]["text"] if not text and tweet["retweeted_status"]
    text = tweet["text"] if not text

    if tweet["quoted_status"]
      quoted = "\n\nRT @#{tweet["quoted_status"]["user"]["screen_name"]} #{tweet["quoted_status"]["full_text"]}"
      text = text.gsub(tweet["quoted_status_permalink"]["url"], "") + quoted
    end
    if tweet["in_reply_to_screen_name"] and not text.includes? tweet["in_reply_to_screen_name"]
      text = "@#{tweet["in_reply_to_screen_name"]} " + text
    end

    return text
  end

  def replace_urls(text, tweet)
    return text unless tweet["entities"]
    (tweet["entities"]["urls"] or []).each do |url|
      text = text.gsub(url["url"], "<a href='#{url["expanded_url"]}' target='_blank'>#{url["display_url"]}</a>").html_safe
    end
    (tweet["entities"]["media"] or []).each do |media|
      text = text.gsub(media["url"], "<a href='#{media["media_url_https"]}' target='_blank'>#{media["display_url"]}</a>").html_safe
    end
    (tweet["entities"]["hashtags"] or []).each do |hashtag|
      text = text.gsub("##{hashtag["text"]}", "<a href='https://twitter.com/hashtag/#{hashtag["text"]}' target='_blank'>##{hashtag["text"]}</a>").html_safe
    end
    text = text.gsub(/@([^\s]+)/, '<a href="/\1">@\1</a>').html_safe
    return text
  end

  def format_tweet(tweet)
    text = full_text(tweet)
    text = replace_urls(text, tweet)
    text = replace_urls(text, tweet["quoted_status"]) if tweet["quoted_status"]
    text = text.gsub("\n", "<br />").html_safe
    return text
  end
end