class PrepareMorphingFoldersToSubprojects < ActiveRecord::Migration
  def change
    add_column :nodes, :once_created_as_folder_type, :boolean
  end
end
