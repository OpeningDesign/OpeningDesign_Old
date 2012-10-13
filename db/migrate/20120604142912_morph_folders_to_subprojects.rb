class MorphFoldersToSubprojects < ActiveRecord::Migration
  def up
    execute <<-SQL
      update nodes set type = 'Project',
        once_created_as_folder_type = #{ActiveRecord::Base.connection.quoted_true}
        where type = 'Folder'
    SQL
  end

  def down
    execute <<-SQL
      update nodes set type = 'Folder',
        once_created_as_folder_type = NULL
        where once_created_as_folder_type = #{ActiveRecord::Base.connection.quoted_true}
    SQL
  end
end
