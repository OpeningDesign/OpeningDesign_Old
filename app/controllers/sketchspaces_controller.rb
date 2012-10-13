class SketchspacesController < ApplicationController
  before_filter :retrieve_sketchspace_by_check_param_or_old_id
  filter_resource_access :member => [:show, :edit, :update, :destroy] # TODO: not sure if :member necessary
  before_filter :authenticate_user!, :only => [:new, :create, :edit, :destroy, :cloned, :submitted]

  def new
    @node = Node.find(params[:node_id])
    @sketchspace = Node.build_sketchspace("New Sketchspace")
    @sketchspace.parent = @node

    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    @ss = Sketchspace.find(params[:id])
  end

  def show
    @sketchspace = Sketchspace.find(params[:id])
    @sketchspace_url = @sketchspace.determine_show_url(current_user)
    current_user.set_sketchspace_cookie(cookies) if current_user
    @doc_version = DocumentVersion.new # for uploads
  end

  def create
    @sketchspace = Sketchspace.create_by_user(current_user, params[:sketchspace])
    respond_to do |format|
      if @sketchspace.persisted?
        format.html { redirect_to @sketchspace, :notice => 'Sketchspace was successfully created.' }
        format.js
      else
        format.html { render :action => 'new' }
      end
    end
  end

  def update
    @sketchspace = Sketchspace.find(params[:id])
    respond_to do |format|
      if @sketchspace.update_by_user(current_user, params[:sketchspace])
        format.html { redirect_to @sketchspace, notice: 'Sketchspace was successfully updated.' }
        format.json { head :ok }
        format.js { flash[:notice] = 'Sketchspace was successfully updated.' }
      else
        format.html { render :action => 'edit' }
        format.json { render json: @sketchspace.errors, :status => :unprocessable_entity }
        format.js { flash[:notice] = "Unable to update sketchspace: #{@sketchspace.errors.full_messages.join(", ")}" }
      end
    end
  end

  def destroy
    @ss = Sketchspace.find(params[:id])
    raise NotAuthorizedException.new() unless @ss.writable_by? current_user
    @ss.destroy
    respond_to do |format|
      format.html { redirect_to @ss.parent, :notice => "Sketchspace successfully deleted." }
      format.json { head :ok }
    end
  end

  def authorized
    begin
      Rails.logger.info "Is #{params[:cookie]} authorized to access #{params[:check]}?"
      raise "missing parameter 'cookie'" unless params[:cookie]
      raise "missing parameter 'check'" unless params[:check]
      pad_id = Sketchspace.guess_pad_id(params[:check])
      Rails.logger.info "guessing pad_id: #{pad_id}"
      ss = Sketchspace.find_by_pad_id(pad_id)
      user = User.consume_sketchspace_cookie(params[:cookie])
      # TODO: if unknown ss, then we can allow access
      if params[:readonly] == 'r'
        granted = user ? true : false # if there's a user (i.e. you are logged in), then you can see it
      else
        granted = ss && user && (ss.is_open_source || ss.collaborator?(user))
      end
      Rails.logger.info "Is #{params[:cookie]} authorized to access #{params[:check]}? #{granted ? 'yes!' : 'no'}"
      render :json => { :access_granted => granted ? true : false }
    rescue Exception => e
      render :json => { :error => e.to_s }
    end
  end

  def cloned
    # called with params 'old' and 'new'
    raise "params 'old' and 'new' required'" unless params[:old] && params[:new]

    @old_sketchspace = Sketchspace.find_by_pad_id(params['old'])
    @new_sketchspace = Sketchspace.new(@old_sketchspace.attributes)
    @new_sketchspace.attributes = {:name => '' + @old_sketchspace.name + ' ' + Time.now.strftime("%d-%m-%y-%H:%M.%S"),
                                   :description => "Clone of " + @old_sketchspace.name,
                                   :pad_id => params[:new]}
    @new_sketchspace.parent = @old_sketchspace
    @new_sketchspace.owner = current_user
    @new_sketchspace.save!
    @new_sketchspace.pad_id = params[:new]
    @new_sketchspace.save!

    respond_to do |format|
      format.html { redirect_to(@new_sketchspace, :notice => I18n.t(".cloned", :default => "Sketchspace successfully cloned.")) }
    end
  end

  def submitted
    # called with params padId and closed (boolean)
    raise "parameter 'padId' required" unless params[:padId]
    @sketchspace = Sketchspace.find_by_pad_id(params[:padId])
    raise "sketchspace with id #{params[:padId]} not found" unless @sketchspace
    Activities.spout_activities_for_user_action(current_user, :submits, @sketchspace, {
      :template => 'activities/user_submits_sketchspace',
      :display_name => current_user.display_name
    })
    redirect_to @sketchspace.parent, :notice => I18n.t(".submitted", :default => "Sketchspace successfully submitted.")
  end

  protected

  def retrieve_sketchspace_by_check_param_or_old_id
    if params[:check]
      @sketchspace = Sketchspace.new # TODO: fake!
    end
    if params['old']
      @sketchspace = Sketchspace.find_by_pad_id(params['old'])
    end
    if params[:padId]
      @sketchspace = Sketchspace.new # fake
    end
  end

end
