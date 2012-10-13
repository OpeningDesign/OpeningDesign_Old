class CollaborationRequestsController < ApplicationController

  def create
    @request = CollaborationRequest.new(params[:collaboration_request])
    @request.user = current_user
    if @request.save
      redirect_to @request.node, :notice => I18n.t('.successfully_created', :default => 'Invitation created successfully.')
    else
      render :action => :new
    end
  end

end
