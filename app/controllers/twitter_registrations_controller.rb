class TwitterRegistrationsController < ApplicationController

  def new
    @user = User.new
    render 'registrations/twitter'
  end

  def create
    data = session[ 'devise.twitter_data' ]
    return head(:bad_request) unless data
    @user = User.create_for_twitter_oauth(data, params[:user][:email])
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
      sign_in_and_redirect @user, :event => :authentication
    else
      render 'registrations/twitter'
    end
  end

end
