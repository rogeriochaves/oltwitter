class HomeController < ApplicationController
  rescue_from Twitter::Error::BadRequest, with: :try_reauth
  rescue_from Twitter::Error::Unauthorized, with: :try_reauth
  before_action :authenticate, except: [:index, :error_test, :privacy]

  def index
    if params[:debug]
      session[:debug] = true
    end

    if session[:auth]
      @tweets = Rails.cache.fetch("timeline_#{session[:auth]["info"]["id"]}", expires_in: 3.minutes) do
        puts "Fetching timeline..."
        twitter.home_timeline(tweet_mode: "extended", count: 50)
      end
      @user = session[:auth]["info"]
    else
      @trends = ["White Stripes", "Joseph Gordon-Lewitt", "#oltwitter", "Justin Bieber", "Those are not real trends", "This is using marquee", "Very cool right"]
      @tweets = [
        ["🎉 Now you can go back to the Good Ol' Twitter 🎉

        I’ve rebuilt twitter circa 2011 for all you nostalgic people

        Check it out:
        👉 <a href='https://oltwitter.herokuapp.com/'>oltwitter.herokuapp.com</a>",
        "1222442453833265152"],
        ["Why?

          Twitter was more about text, now there are lots of videos, images, links, threads (like this one), the UI now is a lot busier and the cognitive load is way higher",
          "1222442456513503232"],
        ["Back then if you did want to share a link or an image you had a cost: first is the 140 limit, you had to upload the image somewhere, use a link shortener

          Then because it was mostly text with no embedding, followers wouldn’t click the link, so words were your best weapon",
          "1222442457985626112"
        ],
        ["Also, twitter now is more passive, you can just scroll and like or RT easily, without giving much though to it

          Before you had to copy and paste the tweet to do a RT, and you put your face to it so your followers really knew it was you repeating something",
          "1222442460103745536"
        ],
        ["Also there was no like button, well there was favorite but this was just for yourself, it wouldn’t show on other’s feed, and it was not that popular first, so if you liked something you had to say it, with words - wow so much work!",
          "1222442461458583552"
        ],
        [ "I feel that all this together with having a normal feed (not algorithmic) caused people to be on twitter to create and read more original content, from people they discovered and chose to follow directly",
          "1222442462981107714"
        ],
        [ "Now I feel I see lots of content that are not really original content from my followers, but somewhat popular tweets from people I don’t care

          Twitter became Facebook right under our noses, I want to go back",
          "1222442464402989057"
        ],
        [
          "If you’d like to contribute, here is the github link: <a href='https://github.com/rogeriochaves/oltwitter/' target='_blank'>github.com/rogeriochaves/oltwitter</a>",
          "1222442465833209861"
        ]
      ]
      render "home", layout: false
    end
  end

  def privacy
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

  def error_test
    raise "this will be reported"
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
