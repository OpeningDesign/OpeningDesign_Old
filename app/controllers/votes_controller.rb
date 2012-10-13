class VotesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @node = Node.find(params[:node_id])
    @user_vote = UserToNode.get(current_user, @node)
    @user_vote.save
  end

  def update
    @node = Node.find(params[:node_id])
    @user_vote = UserToNode.get(current_user, @node)
    if @node.owner == current_user
      redirect_to @node, :notice => "You are not authorized to vote on your own node"
      return
    end
    if @node.collaborator?(current_user) && @user_vote.has_voted(params[:user_to_node][:vote])
      redirect_to @node, :notice => "Thanks for your vote."
    elsif !@node.collaborator?(current_user)
      redirect_to @node, :notice => "You are not authorized to vote on this"
    else
      render :action => :index
    end
  end

  def destroy
    @node = Node.find(params[:node_id])
    @user_vote = UserToNode.get(current_user, @node)
    @user_vote.remove_vote
    redirect_to node_votes_path(@node), :notice => "Your vote has been removed"
  end

end
