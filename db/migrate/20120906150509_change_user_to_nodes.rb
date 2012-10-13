class ChangeUserToNodes < ActiveRecord::Migration
  def change
    change_column :user_to_nodes, :vote, :integer, :default => 0
  end
end
