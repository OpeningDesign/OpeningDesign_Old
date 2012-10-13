class CreateSocialConnections < ActiveRecord::Migration
  def self.up
    create_table :social_connections do |t|
      t.integer :source_id
      t.string :source_type
      t.integer :target_id
      t.string :target_type
      t.timestamps
    end
    create_table :social_activities do |t|
      t.integer :owner_id
      t.string :owner_type
      t.integer :subject_id
      t.string :subject_type
      t.integer :target_id
      t.string :target_type
      t.string :verb
      t.text :options_as_json
      t.boolean :unseen, :default => true
      t.timestamps
    end
  end
  def self.down
    drop_table :social_connections
    drop_table :social_activities
  end
end
