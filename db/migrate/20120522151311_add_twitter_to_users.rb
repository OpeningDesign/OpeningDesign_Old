class AddTwitterToUsers < ActiveRecord::Migration
  def change
    add_column :users, :twitter_id, :string
    add_index :users, :twitter_id, :unique => true
  end
end
