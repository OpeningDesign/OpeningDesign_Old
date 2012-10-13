class AddVotingToUserToNode < ActiveRecord::Migration
  def change
    add_column :user_to_nodes, :vote, :integer
    add_column :user_to_nodes, :voted, :boolean
  end
end
