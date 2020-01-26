class SessionsController < ApplicationController
  def create
    session[:auth] = {
      access_token: auth_hash.extra.access_token.token,
      access_token_secret: auth_hash.extra.access_token.secret,
      info: auth_hash.extra.raw_info
    }
    redirect_to '/'
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end