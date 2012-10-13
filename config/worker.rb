require 'stalker'
include Stalker
require File.expand_path("../environment", __FILE__)

job 'digest-email.prepare-and-send' do |args|
  Rails.logger.info "preparing and sending digest emails now"
  DailyDigestMailer.prepare_and_mail_all()
end

job 'node.update-popularity-scores' do |args|
  t0 = Time.now
  Rails.logger.info "updating popularity scores now"
  Node.update_popularity_scores
  Rails.logger.info "updating popularity scores finished in #{Time.now - t0} seconds"
end

job 'node.update-images' do |args|
  Rails.logger.info "updating node images"
  n = 0
  Node.by_dirty_node_images.each do |node|
    node.update_attribute :node_images_dirty, false
    node.regenerate_node_images
    n += 1
  end
  Rails.logger.info "updating node images for #{n} nodes finished."
end

job 'activity.user-tags-node' do |args|
  user = User.find(args["user"])
  node = Node.find(args["node"])
  tag_name = args["tag"]
  Rails.logger.info "user=#{user}, node=#{node}, tag_name=#{tag_name}"

  # Mhmhm... need to notify those that are subscribed to the project *AND* those subscribed to the tag
  # 'Chris tagged "project 42" with "YetAnotherTag"'
  # We solve it by adding the tag subscribers as 'additional_recipients'
  tag = ActsAsTaggableOn::Tag.find_by_name(tag_name)
  tag_subscribers = SocialConnection.incoming(tag).collect {|c| c.source }
  user.tags(node,
            :template => 'activities/user_tags_node',
            :display_name => user.display_name,
            :node => node.to_param,
            :additional_recipients => tag_subscribers,
            :tag_id => tag.to_param,
            :tag => tag.name)
  Rails.logger.info("successfully created social activities for user #{user} tagging a node")
end
