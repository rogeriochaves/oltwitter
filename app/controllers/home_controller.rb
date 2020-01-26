class HomeController < ApplicationController
  rescue_from Twitter::Error::BadRequest, with: :try_reauth
  before_action :authenticate

  def index
    @tweets = Rails.cache.fetch("timeline_#{session[:auth]["info"]["id"]}", expires_in: 2.minutes) do
      puts "Fetching timeline..."
      twitter.home_timeline(tweet_mode: "extended", count: 50)
    end
    @user = session[:auth]["info"]
  end

  def profile
    @user = Rails.cache.fetch("profile_#{params[:screen_name]}", expires_in: 1.hour) do
      puts "Fetching profile..."
      twitter.user(params[:screen_name])
    end
    puts "user #{@user.inspect}"
    @tweets = Rails.cache.fetch("timeline_profile_#{params[:screen_name]}", expires_in: 2.minutes) do
      puts "Fetching profile timeline..."
      twitter.user_timeline(params[:screen_name], tweet_mode: "extended", count: 50)
    end
  end

  def new
    puts "tweeted #{params[:tweet]}"

    redirect_to "/"
  end

  private
  def authenticate
    unless session[:auth]
      redirect_to '/auth/twitter'
      return false
    end
  end

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
