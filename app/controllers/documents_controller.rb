class DocumentsController < ApplicationController
  filter_resource_access
  before_filter :authenticate_user!, :except => [:show]

  def new
    @parent = Node.find(params[:parent_id]) # actually, the parent
    @document = Document.new(:name => 'New document', :parent => @parent)
  end

  def create
    respond_to do |format|
      @document = Document.create_by_user(current_user, params[:document])
      if @document.persisted?
        format.html { redirect_to @document, notice: 'Document was successfully created.' }
        format.json { render json: @document, status: :created, location: @document }
      else
        @parent = @document.parent
        format.html { render :action => 'new', parent_id: @document.parent.id }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
  end

  def download
    @document = Document.find(params[:id])
    @version = @document.latest_version
    @version.update_attribute(:downloads_count, @version.downloads_count + 1)
    redirect_to @version.content.expiring_url(3)
  end

  def show
    @document = Document.find(params[:id])
  end

  def destroy
    @document = Document.find(params[:id])
    @parent = @document.parent
    raise NotAuthorizedException.new() unless @document.writable_by? current_user
    @document.destroy
    respond_to do |format|
      format.html { redirect_to request.referer, :notice => "Document #{@document.name} was successfully deleted." }
    end
  end

end
