class ChangeUniquenessOfNamesOnNodes < ActiveRecord::Migration

  def up
    remove_index :nodes, :name => "index_nodes_on_parent_id_and_name"
    add_index :nodes, ["parent_id", "name", "version"],
      :name => "index_nodes_on_parent_id_and_name_and_version", :unique => true
  end

  def down
    remove_index :nodes, :name => "index_nodes_on_parent_id_and_name_and_version"
    add_index "nodes", ["parent_id", "name"], :name => "index_nodes_on_parent_id_and_name", :unique => true
  end

end
