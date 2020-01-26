class HomeController < ApplicationController
  rescue_from Twitter::Error::BadRequest, with: :try_reauth

  def index
    unless session[:auth]
      redirect_to '/auth/twitter'
      return
    end

    @tweets = Rails.cache.fetch("timeline_#{session[:auth]["info"]["id"]}", expires_in: 2.minutes) do
      puts "Fetching twitter..."
      twitter.home_timeline(tweet_mode: "extended", count: 50)
    end
    @user = session[:auth]["info"]
  end

  private
  def twitter
    auth = session[:auth]

    Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = auth["access_token"]
      config.access_token_secret = auth["access_token_secret"]
    end
  end

  def try_reauth(exception)
    if exception.to_s == "Bad Authentication data."
      redirect_to '/auth/twitter'
    end
  end
end
