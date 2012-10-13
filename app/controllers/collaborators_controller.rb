class CollaboratorsController < ApplicationController

  before_filter :authenticate_user!, :except => [:index]

  # TODO: quite confusing:
  # @collaborators is the list of collaborators on the node
  # @collaboration_request is a request by a user to be added as a new collaborator
  # @collaborator_to_add is used if the current_user owns the node and wants to add a new collab straight away.
  #
  # We are also using index and create actions, not the show or new action right now.
  def index
    @node = Node.find(params[:node_id])
    @collaborators = @node.collaborators
    @collaboration_request = current_user.collaboration_requests.build if current_user
    @collaborator_to_add = CollaboratorToAdd.new(params[:collaborator_to_add] || {})
    @users_by_name = User.find_all_by_name(@collaborator_to_add.name_or_email) unless @collaborator_to_add.name_or_email.blank?
    if @users_by_name && @users_by_name.count > 1
      @ambiguous = true
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @collaborators }
    end
  end

  # POST /collaborators
  # POST /collaborators.json
  def create
    @node = Node.find(params[:node_id])
    @collaborators = @node.collaborators
    # TODO: next line only here, because we may render the 'index' action which may need this
    @collaboration_request = current_user.collaboration_requests.build if current_user
    @collaborator_to_add = CollaboratorToAdd.new(params[:collaborator_to_add] || {}) # needed when we render the index... (arghh, ugly)
    @username = ''

    if params[:user_id]
      @user = User.find(params[:user_id])
      @username = @user.name if @user
    else
      @collaborator_to_add = CollaboratorToAdd.new(params[:collaborator_to_add] || {})
      @users_by_name = User.find_all_by_name(@collaborator_to_add.name_or_email)
      if @users_by_name && @users_by_name.count > 1
        @ambiguous = true
        render :action => "index"
        return
      end
      @user = @users_by_name.first || User.find_by_email(@collaborator_to_add.name_or_email)
      @username = @user.name if @user
      @username ||= @collaborator_to_add.name_or_email
    end

    if @user.blank?
      redirect_to node_collaborators_path(@node), notice: "User #{@username} could not be found, please try again."
      return
    elsif @user == current_user
      redirect_to node_collaborators_path(@node), :notice => "You cannot add yourself as a collaborator."
      return
    end
    @collaborator = @node.collaborators.build(:user => @user)

    respond_to do |format|
      if @collaborator.save
        format.html { redirect_to node_collaborators_path(@node), notice: "#{@collaborator.user.name} was added successfully as a collaborator." }
        format.json { render json: @collaborator, status: :created, location: @collaborator }
      else
        flash.notice = @collaborator.errors.messages.values.join()
        format.html { redirect_to node_collaborators_path(@node), :notice => flash.notice }
        format.json { render json: @collaborator.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /collaborators/1
  # PUT /collaborators/1.json
  def update
    @collaborator = Collaborator.find(params[:id])

    respond_to do |format|
      if @collaborator.update_attributes(params[:collaborator])
        format.html { redirect_to @collaborator, notice: 'Collaborator was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @collaborator.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collaborators/1
  # DELETE /collaborators/1.json
  def destroy
    @collaborator = Collaborator.find(params[:id])
    @node = @collaborator.node
    @user = @collaborator.user
    unless @node.owner == current_user
      redirect_to node_collaborators_path(@node), :notice => "You are not authorized to do this"
      return
    end
    @collaborator.destroy

    respond_to do |format|
      format.html { redirect_to node_collaborators_path(@node), :notice => "User #{@user.name} has been removed as a collaborator." }
      format.json { head :ok }
    end
  end
end
