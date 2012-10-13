class AddDocumentVersionAttributesToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :content_file_name, :string
    add_column :nodes, :content_content_type, :string
    add_column :nodes, :content_file_size, :integer
    add_column :nodes, :content_updated_at, :datetime
    add_column :nodes, :version, :integer
    add_column :nodes, :downloads_count, :integer
  end
end
