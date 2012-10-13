class AddLinkedinToUsers < ActiveRecord::Migration
  def change
    add_column :users, :linkedin_id, :string
    add_index :users, :linkedin_id, :unique => true
  end
end
