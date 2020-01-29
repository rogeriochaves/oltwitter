class HomeController < ApplicationController
  rescue_from Twitter::Error::BadRequest, with: :try_reauth
  rescue_from Twitter::Error::Unauthorized, with: :try_reauth
  before_action :authenticate

  def index
    @tweets = Rails.cache.fetch("timeline_#{session[:auth]["info"]["id"]}", expires_in: 3.minutes) do
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
    @tweets = Rails.cache.fetch("timeline_profile_#{params[:screen_name]}", expires_in: 3.minutes) do
      puts "Fetching profile timeline..."
      twitter.user_timeline(params[:screen_name], tweet_mode: "extended", count: 50)
    end
  end

  def new
    if params[:in_reply_to].empty?
      twitter.update(params[:tweet])
      puts "Tweeted #{params[:tweet]}"
    else
      twitter.update(params[:tweet], { in_reply_to_status_id: params[:in_reply_to] })
      puts "Tweeted #{params[:tweet]} in reply to #{params[:in_reply_to]}"
    end
    Rails.cache.delete("timeline_#{session[:auth]["info"]["id"]}")

    redirect_to "/"
  end

  def _timeline
    if params[:after]
      puts "Fetching olders tweets..."
      @tweets = Rails.cache.fetch("timeline_after_#{params[:after]}", expires_in: 1.hour) do
        @tweets = twitter.home_timeline(tweet_mode: "extended", count: 50, max_id: params[:after].to_i)
        @tweets = @tweets[1..]
      end
    elsif params[:before]
      puts "Fetching newer tweets..."
      @tweets = twitter.home_timeline(tweet_mode: "extended", count: 50, since_id: params[:before].to_i)
      @tweets = @tweets[0..-2]
    end

    render layout: false
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
    if exception.to_s == "Bad Authentication data." or exception.to_s == "Could not authenticate you."
      redirect_to '/auth/twitter'
    end
  end
end
