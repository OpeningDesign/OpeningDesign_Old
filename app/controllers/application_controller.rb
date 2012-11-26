class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_current_user
  before_filter :display_beta_warning
  before_filter :maybe_cancel_moving_node
  before_filter :beta_features_visible

  def operator_only
    unless !current_user.nil? && current_user.operator?
      flash[:alert] = 'You need to be an operator to do this.'
      redirect_to :root
    end
  end

  def maybe_cancel_moving_node
    if session[:moving_node] && !([ 'show', 'index', 'cancelmove', 'submitmove' ].include? action_name)
      session[:moving_node] = nil # cancels the move
    end
  end

  protected

  def beta_users
    [ 'ryan@openingdesign.com', 'c@test.com', 'christian.oloff@web.de']
  end

  def beta_features_visible
    if current_user && beta_users.include?(current_user.email)
      @beta_features_visible = true
    end
  end

  def display_beta_warning
    return # TODO: disabled
    return unless Rails.env == 'production'
    @display_beta_warning = true unless cookies[:odr_beta_warning_shown]
    cookies[:odr_beta_warning_shown] = { :value => "shown", :expires => 20.minutes.from_now }
  end

  def set_current_user
    Authorization.current_user = current_user
  end

  def permission_denied
    flash[:notice] = "Sorry, you are not authorized to access that page."
    redirect_to root_url
  end

  def render_deferred_children_of(node_id, root_id)
    @node = Node.find(node_id)
    @root = Node.find(root_id)
    render 'nodes/show_children_deferred'
  end
end
