class CreateDocVersions < ActiveRecord::Migration
  def change
    create_table :doc_versions do |t|
      t.integer :node_id
      t.string :content_file_name
      t.string :content_content_type
      t.integer :content_file_size
      t.datetime :content_updated_at

      t.timestamps
    end
  end
end
