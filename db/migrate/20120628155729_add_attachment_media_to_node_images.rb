class AddAttachmentMediaToNodeImages < ActiveRecord::Migration
  def self.up
    change_table :node_images do |t|
      t.has_attached_file :media
    end
  end

  def self.down
    drop_attached_file :node_images, :media
  end
end
