class AddDirtyflagToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :node_images_dirty, :boolean
    add_index :nodes, :node_images_dirty
  end
end
