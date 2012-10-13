class CreateNodeImages < ActiveRecord::Migration
  def change
    create_table :node_images do |t|
      t.references :node
      t.timestamps
    end
  end
end
