class CreateSanctionedTags < ActiveRecord::Migration
  def change
    create_table :sanctioned_tags do |t|
      t.string :name

      t.timestamps
    end
  end
end
