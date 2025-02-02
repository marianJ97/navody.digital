class SessionsController < ApplicationController
  before_action :disable_feedback

  def new
    session[:after_login_callback] = params[:callback]
  end

  def create
    redirect_to new_session_path, alert: 'Prosím zadajte e-mail' and return unless auth_email.present?

    user = User.find_by('lower(email) = lower(?)', auth_email) || User.create!(email: auth_email)

    session[:user_id] = user.id
    redirect_to after_login_redirect_path, notice: 'Prihlásenie úspešné. Vitajte!'
  end

  def magic_link_info
    @email = params[:email]
  end

  def failure
    @message = params[:message]
    @strategy = params[:strategy]
  end

  def destroy
    reset_session

    redirect_to root_path, notice: 'Odhlásenie bolo úspešné.'
  end

  protected

  def auth_email
    auth_hash.dig('info', 'email')
  end

  def auth_hash
    request.env['omniauth.auth']
  end

  private

  def after_login_redirect_path
    return session[:after_login_callback] if session[:after_login_callback]&.start_with?("/") # Only allow local redirects
    root_path
  end
end
