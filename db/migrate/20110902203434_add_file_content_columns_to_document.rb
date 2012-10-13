class AddFileContentColumnsToDocument < ActiveRecord::Migration
  def change
    add_column :nodes, :file_content_file_name, :string
    add_column :nodes, :file_content_content_type, :string
    add_column :nodes, :file_content_file_size, :integer
    add_column :nodes, :file_content_updated_at, :datetime
  end
end
