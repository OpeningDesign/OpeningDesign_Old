class AddSketchspacesToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :pad_id, :string
  end
end
