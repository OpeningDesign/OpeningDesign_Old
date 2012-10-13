class UsersController < ApplicationController

  before_filter :authenticate_user!, :only => [:index, :edit, :destroy, :update, :show]
  before_filter :operator_only, :only => [:index, :edit, :destroy, :update]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @latest_activities = @user.latest_activities
    if current_user && (current_user != @user)
      @can_subscribe = !current_user.connected_to?(@user)
      @can_unsubscribe = !@can_subscribe
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to users_path, notice: 'User successfully updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
  end

  def subscribe
    @user = User.find(params[:user_id])
    current_user.connect_to(@user)
    redirect_to @user, :notice => I18n.t('.subscribed', :default => "Successfully subscribed to %{username}",
                                        :username => @user.display_name)
  end

  def unsubscribe
    @user = User.find(params[:user_id])
    current_user.disconnect_from(@user)
    redirect_to @user, :notice => I18n.t('.unsubscribed', :default => "Successfully unsubscribed from %{username}",
                                        :username => @user.display_name)
  end
end
