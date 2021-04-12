class SessionsController < ApplicationController
  def create
    if session[:debug]
      session[:debug] = nil
      render plain: auth_hash.inspect
      return
    end

    session[:auth] = {
      access_token: auth_hash.extra.access_token.token,
      access_token_secret: auth_hash.extra.access_token.secret,
      info: auth_hash.extra.raw_info
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