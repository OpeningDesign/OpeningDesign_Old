class ProjectsController < ApplicationController
  filter_resource_access
  before_filter :authenticate_user!, :only => [:new, :create, :edit, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])
    @doc_version = DocumentVersion.new # for uploading files

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new
    @project.parent = Node.find(params[:node_id]) if params[:node_id]
    @number_closed_left = current_user ? current_user.number_closed_nodes_left : 0
    @show_open_vs_closed_choice = @project.parent.nil? # only show for root projects

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
      format.js
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /projects
  # POST /projects.json
  def create
    respond_to do |format|
      @project =  Project.create_by_user(current_user, params[:project], params[:node_id])
      if @project.persisted?
        format.html { redirect_to @project, notice: "#{@project.parent ? t("sub_project") : t("project")} was successfully created." }
        format.json { render json: @project, status: :created, location: @project }
        format.js
      else
        @number_closed_left = current_user ? current_user.number_closed_nodes_left : 0
        @show_open_vs_closed_choice = @project.parent.nil? # only show for root projects
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_by_user(current_user, params[:project])
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :ok }
        format.js { flash[:notice] = "Project was successfully updated." }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
        format.js { flash[:notice] = "Unable to update project: #{@project.errors.full_messages.join(", ")}" }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find(params[:id])
    raise NotAuthorizedException.new() unless @project.writable_by? current_user
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :ok }
    end
  end

  def download
    @project = Project.find(params[:project_id])
    file = @project.create_temporary_zipfile
    send_file file, :filename => "#{@project.name}.zip"
  end

end
