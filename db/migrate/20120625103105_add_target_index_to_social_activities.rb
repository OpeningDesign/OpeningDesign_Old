class AddTargetIndexToSocialActivities < ActiveRecord::Migration
  def change
    add_index :social_activities, [:target_id, :target_type, :created_at], :name => 'social_activities_target1'
  end
end
