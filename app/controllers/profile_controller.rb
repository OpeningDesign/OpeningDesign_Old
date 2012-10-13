class ProfileController < ApplicationController

  before_filter :authenticate_user!, :except => [ :display_name ]

  def show
    @user = current_user
    @activities = SocialConnections.aggregate(@user).activities
    @has_more_activities = params[:show_all_activities].nil? && @activities.count > 10
    @activities = @activities[0..9] unless params[:show_all_activities]
    @has_activities = @activities.count > 0
    @my_tags = @user.subscribed_tags
    @my_subscribed_nodes = current_user.subscriptions.collect {|c| c.target }.select {|t| t.respond_to?(:root) }
    @my_subscribed_users = current_user.subscriptions.collect {|c| c.target }.select {|t| t.instance_of?(User) }
    @my_votes = UserToNode.by_user(current_user).voted
  end

  def display_name
    user = User.consume_sketchspace_cookie(params[:cookie])
    render :json => user ? user.display_name : 'unknown user'
  end

end
