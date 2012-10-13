class Collaborator < ActiveRecord::Base
  belongs_to :node
  belongs_to :user

  validates :user_id, :uniqueness => { :scope => :node_id, :message => "User cannot be a collaborator more than once"}

  after_create do |collaborator|
    more_recipients = collaborator.node.determine_additional_recipients
    more_recipients.concat collaborator.node.transitive_collaborators.collect {|c| c.user }
    activities = node.owner.adds_as_collaborator(collaborator.user, :template => 'activities/user_adds_collaborator',
                                    :display_name => node.owner.display_name, :node => node.to_param,
                                    :additional_recipients => more_recipients)
  end
end
