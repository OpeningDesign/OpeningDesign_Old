class CreateCollaborators < ActiveRecord::Migration
  def change
    create_table :collaborators do |t|
      t.references :node
      t.references :user

      t.timestamps
    end
  end
end
