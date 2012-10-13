class AddExplicitlyOpenSourcedToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :explicitly_open_sourced, :boolean
  end
end
