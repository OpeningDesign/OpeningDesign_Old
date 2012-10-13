class LinkedinRegistrationsController < ApplicationController

  def new
    @user = User.new
    render 'registrations/linkedin'
  end

  def create
    data = session['devise.linkedin_data']
    return head(:bad_request) unless data
    @user = User.create_for_linkedin_oauth(data, params[:user][:email])
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Linkedin"
      sign_in_and_redirect @user, :event => :authentication
    else
      render 'registrations/linkedin'
    end
  end
end
