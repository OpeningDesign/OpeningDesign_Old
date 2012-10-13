class TagsController < ApplicationController

  before_filter :authenticate_user!, :except => [ :index ]

  def show
    @tagname = CGI.unescape(params[:id])
    @tag = ActsAsTaggableOn::Tag.find_by_name(@tagname)
    @can_subscribe = !current_user.nil? && !current_user.connected_to?(@tag)
    @can_unsubscribe = !current_user.nil? && current_user.connected_to?(@tag)
    @nodes = Node.tagged_with(@tagname)
  end

  def index
    @node = Node.find(params[:node_id])
    render :json => @node.tags
  end

  def subscribe
    @tag = ActsAsTaggableOn::Tag.find(params[:tag_id])
    current_user.connect_to(@tag)
    redirect_to tag_path(:id => @tag.name), :notice => "Successfully subscribed to tag"
  end

  def unsubscribe
    @tag = ActsAsTaggableOn::Tag.find(params[:tag_id])
    current_user.disconnect_from(@tag)
    redirect_to tag_path(:id => @tag.name), :notice => "Successfully unsubscribed from tag"
  end

  def create
    node = Node.find(params[:node_id])
    node.tag_list << params[:tag]
    if node.save
      Stalker.enqueue('activity.user-tags-node',
                      :user => current_user.to_param,
                      :node => node.to_param,
                      :tag => params[:tag])
      render :json => { :tag => params[:tag] }
    else
      render :json => node.errors, :status => :unprocessable_entity
    end
  end

end
