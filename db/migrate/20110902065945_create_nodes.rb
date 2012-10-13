class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :name
      t.string :description
      t.integer :owner_id
      t.integer :parent_id
      t.string :type

      t.timestamps
    end
    add_index :nodes, [:parent_id, :name], :unique => true
    add_index :nodes, :type
  end
end
