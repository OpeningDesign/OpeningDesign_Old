class AddUsers2Nodes < ActiveRecord::Migration
  def change
    create_table :user_to_nodes do |t|
      t.references :user
      t.references :node
      t.boolean :collapsed, :default => false
    end
    add_index :user_to_nodes, [:user_id, :node_id], :unique => true
  end
end
