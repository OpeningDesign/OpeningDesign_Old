class NodesController < ApplicationController
  filter_access_to :all
  before_filter :authenticate_user!

  def upload
    begin
      if params[:new_version_only]
        params[:document_version][:new_version_only] = true
      end
      @node = Node.find(params[:id])
      @documents = @node.upload_documents_by_user(current_user, @node, params[:document_version])
      render :json => { :document_name => @documents.collect{|d| d.display_name}.join(", "), :content_type => 'text/html' }
    rescue => e
      render :json => { :error => e.to_s }, :status => 500
    end
  end

  # We can use e.g. `node_url(node)`, which then redirects to the correct controller.
  # TODO: it might be cleaner to only use nodes#show, instead of the specific project#show, document#show etc.
  def show
    redirect_to Node.find(params[:id])
  end

  def show_children_deferred
    @node = Node.find(params[:node])
    @root = Node.find(params[:root])
  end

  def update
    @node = Node.find(params[:id])
    @node.collapse_by_user(current_user, params[:collapsed])
    head :ok
  end

  def delete_tag
    node = Node.find(params[:node_id])
    node.tag_list.delete(params[:tag])
    node.save
    head :ok
  end

  def subscribe
    node = Node.find(params[:node_id])
    current_user.connect_to(node)
    redirect_to node, :notice => I18n.t('.subscribed', :default => "Successfully subscribed to %{display_name}", :display_name => node.display_name)
  end

  def unsubscribe
    node = Node.find(params[:node_id])
    current_user.disconnect_from(node)
    redirect_to node, :notice => I18n.t('.unsubscribed', :default => "Successfully unsubscribed from %{display_name}", :display_name => node.display_name)
  end

  def move
    node = Node.find(params[:node_id])
    session[:moving_node] = node.to_param if node
    redirect_to request.referer, :notice => I18n.t('.moving', :default => "Now select where you want to move %{node_name} to.", :node_name => node.display_name)
  end

  def cancelmove
    node = Node.find(session[:moving_node])
    session[:moving_node] = nil
    redirect_to request.referer, :notice => I18n.t('.cancelmoving', :default => "Moving of %{node_name} cancelled.", :node_name => node.display_name)
  end

  def submitmove
    node = Node.find(session[:moving_node])
    target = Node.find(params[:node_id])
    if node.nil? || target.nil?
      return head(:bad_request)
    end
    if target.is_self_or_child_of? node
      raise "Cannot move #{node.display_name} to itself or a child of itself"
    end

    # old and new parent may have to update node images
    node.parent.update_column(:node_images_dirty, true) if node.parent
    target.update_column(:node_images_dirty, true)

    node.parent = target
    if node.save
      session[:moving_node] = nil
      redirect_to request.referer, :notice => I18n.t('.submitmove',
                                                     :default => "Node %{node_name} moved into %{target_name}",
                                                     :node_name => node.display_name,
                                                     :target_name => target.display_name)
    else
      redirect_to request.referer, :notice => I18n.t('.submitmove_error',
                                                    :default => "Unable to move %{node_name} due to a server error",
                                                    :node_name => node.display_name)
    end
  end

end
