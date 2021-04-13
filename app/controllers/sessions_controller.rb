class SessionsController < ApplicationController
  def create
    info = auth_hash.extra.raw_info
    session[:auth] = {
      access_token: auth_hash.extra.access_token.token,
      access_token_secret: auth_hash.extra.access_token.secret,
      info: {
        id: info.id,
        profile_image_url_https: info.profile_image_url_https,
        screen_name: info.screen_name,
        statuses_count: info.statuses_count,
        friends_count: info.friends_count,
        followers_count: info.followers_count,
        listed_count: info.listed_count,
      }
    }
    redirect_to '/'
  end

  def failure
    render plain: "Auth error: #{params[:message]}, please contact @_rchaves_ on twitter"
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end