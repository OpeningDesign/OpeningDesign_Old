class AddVoteAttributesToNode < ActiveRecord::Migration
  def change
    add_column :nodes, :vote_count, :integer, :default => 0
    add_column :nodes, :vote_sum, :integer, :default => 0
  end
end
