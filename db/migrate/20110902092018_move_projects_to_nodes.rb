class MoveProjectsToNodes < ActiveRecord::Migration

  class OldProject < ActiveRecord::Base
    set_table_name "projects"
    acts_as_connectable verbs: []
  end

  def up
    # cleanup
    Project.all.each do |p|
      p.destroy
    end
    # copy
    OldProject.all.each do |old|
      puts "old=#{old.attributes}"
new_attribs = old.attributes.except(:id)
new_attribs[:description] = new_attribs[:description].truncate(160) rescue ""
      new = Project.create(new_attribs)
      puts "new.errors.count=#{new.errors.count}"
      if new.errors.count > 0
        puts "ERRORS, continue"
        next
      end
      SocialConnection.all.select {|c| c.target_id == old.id && c.target_type == 'Project'}.each do |c|
        execute "update social_connections set target_id = #{new.id}, target_type = 'TEMP' where id = #{c.id}"
        puts "social_connection changed: #{c.id}"
      end
      SocialActivity.all.select {|a| a.target_id == old.id && a.target_type == 'Project'}.each do |a|
        execute "update social_activities set target_id = #{new.id}, target_type = 'TEMP' where id = #{a.id}"
        puts "social activity changed: #{a.id}"
      end
    end
    # change the 'TEMP' type
    execute "update social_activities set target_type = 'Project' where target_type = 'TEMP'"
    execute "update social_connections set target_type = 'Project' where target_type = 'TEMP'"
  end

  def down
    raise "cannot revert"
  end
end
