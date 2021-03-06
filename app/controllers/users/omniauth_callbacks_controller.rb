class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    @user = User.find_for_facebook_oauth(env["omniauth.auth"], current_user)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @user, :event => :authentication
    else
      #session["devise.facebook_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def twitter
    @user = User.find_for_twitter_oauth(env['omniauth.auth'], current_user)
    if @user
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
      sign_in_and_redirect @user, :event => :authentication
    else
      puts "redirecting"
      session["devise.twitter_data"] = env["omniauth.auth"]
      redirect_to new_twitter_registration_url
    end
  end

  def linkedin
    @user = User.find_for_linkedin_oauth(env["omniauth.auth"], current_user)
    if @user
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Linkedin"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.linkedin_data"] = env["omniauth.auth"]
      redirect_to new_linkedin_registration_url
    end
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

end

