module ApplicationHelper
  def tag_links(text)
    text.gsub(/(http\S+)/, '<a href="\1" target="_blank">\1</a>').html_safe
  end

  def full_text(tweet)
    json = tweet.as_json
    rt = "RT @#{json['retweeted_status']['user']['screen_name']} " if json['retweeted_status']
    return rt + json['retweeted_status']['extended_tweet']['full_text'] if json['retweeted_status'] and json['retweeted_status']['extended_tweet']
    return rt + json['retweeted_status']['full_text'] if json['retweeted_status']
    return json['extended_tweet']['full_text'] if json['extended_tweet']
    return json['full_text'] if json['full_text']
    return rt + json['retweeted_status']['text'] if json['retweeted_status']
    return json['text']
  end

  def format_tweet(tweet)
    text = full_text(tweet)
    if tweet.retweeted_status and tweet.retweeted_status.media and tweet.retweeted_status.media[0]
      url = tweet.retweeted_status.media[0].url
      media_url = tweet.retweeted_status.media[0].media_url_https
      return text.gsub(url, "") + media_url
    elsif tweet.media and tweet.media[0]
      url = tweet.media[0].url
      media_url = tweet.media[0].media_url_https
      return text.gsub(url, "") + media_url
    end
    return text
  end
end
