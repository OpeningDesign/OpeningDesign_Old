class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :full_name,
    :email, :password, :password_confirmation, :remember_me, :sketchspace_cookie,
    :twitter_id, :linkedin_id
  has_many :projects, :foreign_key => "owner_id"
  has_many :collaboration_requests
  has_many :user_to_nodes
  belongs_to :associated_subscription_plan, :class_name => "SubscriptionPlan"

  acts_as_connectable verbs: [ :creates, :updates, :signs_up,
                               :adds_as_collaborator, :tags, :submits ]

  include Gravtastic
  gravtastic

  def self.find_for_twitter_oauth(auth_info, signed_in_user = nil)
    if user = User.find_by_twitter_id(auth_info.uid)
      user.full_name = auth_info.info.name
      user.save if user.changed?
      user
    else
      nil
    end
  end

  def self.create_for_twitter_oauth(auth_info, email)
    User.create(:email => email, :password => Devise.friendly_token[0, 8],
               :full_name => auth_info.info.name, :twitter_id => auth_info.uid)
  end

  def self.find_for_linkedin_oauth(auth_info, signed_in_user = nil)
    data = auth_info.extra.raw_info
    if user = User.find_by_linkedin_id(data.id)
      user.first_name = data.firstName
      user.last_name = data.lastName
      user.save if user.changed?
      user
    else
      nil
    end
  end

  def self.create_for_linkedin_oauth(auth_info, email)
    data = auth_info.extra.raw_info
    User.create(:email => email, :password => Devise.friendly_token[0, 8],
               :first_name => data.firstName, :last_name => data.lastName, :linkedin_id => data.id)
  end

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    if user = User.find_by_email(data["email"])
      user.first_name = data['first_name']
      user.last_name = data['last_name']
      user.facebook_id = data['id']
      user.save if user.changed?
      user
    else # Create a user with a stub password.
      User.create(:email => data["email"], :password => Devise.friendly_token[0,20],
                  :first_name => data['first_name'], :last_name => data['last_name'],
                 :facebook_id => data['id'])
    end
  end

  # finds a user by sketchspace cookie and "consumes" it (i.e. invalidates it)
  def self.consume_sketchspace_cookie(value)
    user = User.find_by_sketchspace_cookie(value)
    # TODO: actually doesn't consume it any more... refactor!
    #user.update_attributes!(:sketchspace_cookie => nil) if user
    user
  end

  # required for declarative_authorization's change support, see
  # https://github.com/stffn/declarative_authorization/#authorization-development-support
  def login
    email
  end

  def root_projects
    Project.root_projects_of_user(self)
  end

  def name
    full_name || "#{first_name} #{last_name}"
  end

  def self.find_by_name(name)
    # TODO: inefficient (full table scan), but the use cases for this
    # method will probably go away / change anyway, thus okay for now.
    self.find_all_by_name(name).first
  end

  def self.find_all_by_name(name)
    all.select {|u| "#{u.first_name} #{u.last_name}" == name}
  end

  def operator?
    operators = [ 'ryan@openingdesign.com', 'chris.oloff@alacrity.co.za', 'c@test.com' ]
    self.operator || operators.include?(email)
  end

  def display_name
    name
  end

  def latest_activities(limit = 10)
    SocialActivity.by_owner(Activities.instance).
      by_subject(self).
      limit(limit).
      order('created_at desc')
  end

  def subscribed_tags
    outgoing_social_connections.select {|sc| sc.target_type == 'ActsAsTaggableOn::Tag' }.collect {|sc| sc.target }.sort {|a,b| a.name <=> b.name }
  end

  def profile_pic_url
    if facebook_id.blank?
      gravatar_url :size => 50, :default => 'retro'
    else
      "http://graph.facebook.com/#{facebook_id}/picture"
    end
  end

  def gravatar_pic?
    (profile_pic_url =~ /gravatar.com/) != nil
  end

  after_create do |user|
    user.signs_up(user,
                  :template => 'activities/user_signs_up',
                  :display_name => user.display_name,
                 :additional_recipients => [ Activities.instance ])
  end

  def set_sketchspace_cookie(cookies)
    value = SecureRandom.hex(12)
    self.update_attributes!(:sketchspace_cookie => value)
    cookies['OD_COOKIE'] = {
      :value => value,
      :expires => 1.day.from_now,
      :domain => SimpleConfig.domain
    }
  end

  def subscriptions
    outgoing_social_connections.sort { |a,b| a.updated_at <=> b.updated_at }
  end

  def number_of_closed_projects
    Project.by_owner(self).root_projects.select {|p| !p.is_open_source }.count
  end

  def number_closed_nodes_left
    number_of_closed_projects_allowed - number_of_closed_projects
  end

  def number_of_closed_projects_allowed
    current_subscription.max_number_closed_source_nodes_with_default
  end

  def subscription_plan_name
    plan = 'default'
    plan = associated_subscription_plan.name if associated_subscription_plan
    plan
  end

  def current_subscription
    sp = SubscriptionPlan.find_by_name(subscription_plan_name)
    raise "user #{display_name} has no valid, current subscription" unless sp
    sp
  end

  def documentspace_used_in_bytes
    Node.by_owner(self).select {|n| n.type == 'DocumentVersion' }.reduce(0) {|v,e| v += e.content_file_size }
  end

  def role_symbols
    a = [ :user ]
    a << :operator if operator?
    a
  end

end
