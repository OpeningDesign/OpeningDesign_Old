class CollaborationRequest < ActiveRecord::Base
  attr_accessible :message, :user_id, :node_id, :node
  belongs_to :user
  belongs_to :node

  before_create do |request|
    CollaborationRequestMailer.request_invite(request).deliver
  end

end
