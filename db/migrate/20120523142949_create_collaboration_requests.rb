class CreateCollaborationRequests < ActiveRecord::Migration
  def change
    create_table :collaboration_requests do |t|
      t.text :message
      t.references :user
      t.references :node

      t.timestamps
    end
  end
end
