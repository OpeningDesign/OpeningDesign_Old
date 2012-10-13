class AddOwnerIdToProjects < ActiveRecord::Migration
  def change
    change_table :projects do |t|
      t.references :owner
    end
  end
end
