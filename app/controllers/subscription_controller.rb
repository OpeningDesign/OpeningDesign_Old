class SubscriptionController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = current_user
    @current = current_user.current_subscription
    @subscriptions = SubscriptionPlan.all
  end

  # TODO: dummy implementation
  def upgrade
    raise "missing 'plan' parameter" unless params[:plan]
    @plan = SubscriptionPlan.find_by_name(params[:plan])
    raise "unknown plan '#{params[:plan]}'" unless @plan
    current_user.associated_subscription_plan = @plan
    current_user.save!
    redirect_to({ :action => :show }, :notice => "You've been upgraded to plan'#{@plan.title}'. NOTE: This is a prototype implementation for now!")
  end

  # TODO: dummy implementation
  def cancel
    current_user.associated_subscription_plan = nil
    current_user.save!
    redirect_to({ :action => :show }, :notice => "Your subscription has been cancelled. NOTE: This is a prototype implementation for now!")
  end

end
