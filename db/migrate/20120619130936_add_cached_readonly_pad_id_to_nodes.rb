class AddCachedReadonlyPadIdToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :cached_readonly_pad_id, :string
  end
end
