class Node < ActiveRecord::Base
  include ActiveRecord::Acts::Tree

  belongs_to :owner, class_name: "User"
  has_many :collaborators
  has_many :collaboration_requests
  has_many :node_images, :dependent => :destroy
  has_many :user_to_nodes
  acts_as_tree :order => :name
  acts_as_taggable

  validate :valid_subscription_plan_check, :on => :create

  def valid_subscription_plan_check
    errors.add(:explicitly_open_sourced,
               I18n.t("subscriptions.need_higher_plan",
                 :default => "You don't have enough credit for a closed project. Please upgrade your subscription plan.")) if type == 'Project' && !explicitly_open_sourced && parent.nil? && owner.number_closed_nodes_left < 1
  end

  scope :document_versions, lambda {|node| where("parent_id = ? and type = 'DocumentVersion'", node.id) }
  scope :by_popularity, order('popularity_score DESC')
  scope :by_owner, lambda {|owner| where("owner_id = ?", owner.id) }
  scope :by_dirty_node_images, where(:node_images_dirty => true)

  before_destroy do |node|
    SocialActivity.by_target(node).each do |a|
      a.destroy
    end
  end

  def self.inherited(klass)
    super
    define_singleton_method "build_#{klass.name.underscore}" do |name, &block|
      build(klass, name, &block)
    end
  end

  def self.decay_to_zero_duration
    Odr::Application.config.decay_to_zero_duration
  end

  def build_document(name, &block)
    document = Node.build_document(name, &block)
    children << document
    document
  end

  def self.build(type, name, &block)
    node = type.new(:name => name)
    block.call(node) if block_given?
    node
  end

  def is_open_source
    return true if explicitly_open_sourced
    return parent.is_open_source if parent
    false
  end

  def visit(&block)
    block.call(self)
    children.each do |child|
      child.visit(&block)
    end
  end

  def visit_up(&block)
    block.call(self)
    parent.visit_up(&block) if parent
  end

  def self.update_popularity_scores
    Project.root_projects.each do |root|
      root.recursively_update_popularity_score
    end
  end

  def recursively_update_popularity_score
    score = own_popularity_score
    children.each do |child|
      score += child.recursively_update_popularity_score
    end
    update_column :popularity_score, score
    save
    score
  end

  def own_popularity_score
    score = 0.0
    SocialActivity.by_target(self).each do |a|
      aged = 1 - (Time.now - a.created_at) / Node.decay_to_zero_duration
      score += [ 0.0, aged ].max
    end
    score
  end

  def project_should_be_removed # TODO: was called 'project'
    self.class == Project ? self : parent.project
  end

  def writable_by?(user)
    return false if user.blank?
    return user.id == owner.id
  end

  def collaborator?(user)
    return true if owned_by?(user)
    collaborators.each do |c|
      return true if c.user == user
    end
    return parent.collaborator?(user) unless parent.nil?
    false
  end

  def owned_by?(user)
    return !user.blank? && user.id == owner.id
  end

  def permitted_to_add_collaborators?(user)
    return user == owner
  end

  def collapse_by_user(user, collapse)
    u2n = UserToNode.by_user_and_node(user, self).first
    u2n ||= UserToNode.create(:user => user, :node => self)
    u2n.update_attributes!(:collapsed => collapse)
  end

  def collapsed_in_view?(user)
    return collapsed_in_view_default if user.nil?
    u2n = UserToNode.by_user_and_node(user, self).first
    u2n.nil? ? collapsed_in_view_default : u2n.collapsed
  end

  def collapsed_in_view_default
    true
  end

  def level
    parent.nil? ? 0 : (parent.level + 1)
  end

  def upload_documents_by_user(user, node, params)
    Rails.logger.info "params=#{params}"
    params[:content].reduce([]) do |documents, file|
      documents << upload_document_by_user(user, node, file, :new_version_only => params[:new_version_only])
    end
  end

  # TODO: super ugly: in specs, we have the original_filename in a hash,
  # in real life, it comes in as an instance of ActionDispatch::Http::UploadedFile
  # which has it as an attribute. What am I missing here?
  def get_original_filename(content)
    if content.respond_to? :original_filename
      content.original_filename
    else
      content["original_filename"]
    end
  end

  def upload_document_by_user(user, node, file, options = {})
    doc_name = get_original_filename(file)
    doc_name = valid_document_name(doc_name) unless options[:new_version_only]
    doc_version = DocumentVersion.build_document_version(doc_name) do |dv|
      dv.content = file
      dv.owner = user
      dv.version = 1
    end
    check_storage_limit(user, doc_version.content_file_size)
    if self.is_a?(Document) && options[:new_version_only]
      next_version = self.version + 1 rescue 1
      doc_version.assign_attributes(:parent => self, :version => next_version,
                                    :name => doc_name,
                                    :downloads_count => 0)
      children << doc_version
      #self.name = parent.valid_document_name(doc_name)
      self.save!
      doc_version.save!
      # TODO: create activity
      doc_version
    else
      document = Node.build_document(doc_name)
      document.assign_attributes(:owner => user, :name => doc_name)
      children << document
      document.children << doc_version
      doc_version.assign_attributes(:parent => document, :version => 1,
                                    :downloads_count => 0)
      document.save!
      doc_version.save!
      # create activity
      Activities.spout_activities_for_user_action(user, :creates, document, {
        :template => 'activities/user_creates_document',
        :display_name => user.display_name
      })
      document
    end

  end

  def valid_document_name(name)
    if Document.by_parent_and_name(self, name).count == 0
      name
    else
      index = 1
      while ((amended = "#{name} (#{index})") and Document.by_parent_and_name(self, amended).count > 0)
        index += 1
      end
      amended
    end
  end

  def display_name
    self.name
  end

  def self.compare_by_type(a, b)
    if (a.class != b.class)
      if a.class == DocumentVersion
        return -1 # DocumentVersion always first
      end
    end
    return 0
  end

  def self.compare(a, b)
    a.name <=> b.name
  end

  def path_from_root
    if parent
      parent.path_from_root << self
    else
      [ self ]
    end
  end

  def children_ordered
    children.sort do |a,b|
      if (n = Node.compare_by_type(a, b)) != 0
        n
      else
        a.class.compare(a, b)
      end
    end
  end

  def children_without_versions
    children.select { |c| c.type != 'DocumentVersion' }
  end

  def children_versions
    children.select {|c| c.type == 'DocumentVersion' }.sort {|a,b| b.version <=> a.version }
  end

  def indentation_level_in_node_list
    l = level
    visit_up do |n|
      l += 1 if n.type == 'DocumentVersion'
    end
    l
  end

  def update_by_user(user, params, options = { :add_social_update => true })
    raise NotAuthorizedException.new() unless writable_by?(user)
    result = update_attributes(params)
    if result && options[:add_social_update]
      what = self.class.name.underscore
      template_exists = File.exists? Rails.root.join("app", "views", "activities", "_user_updates_#{what}.html.erb")
      user.updates(self,
                  :template => template_exists ? "activities/user_updates_#{self.class.name.underscore}" : nil,
                  :display_name => user.display_name)
    end
    result
  end

  def is_self_or_child_of?(other_node)
    node = self
    while node do
      if node == other_node
        return true
      end
      node = node.parent
    end
    return false
  end

  def determine_additional_recipients
    r = []
    r.concat incoming_social_connections.collect {|c| c.source }
    r.concat(parent.determine_additional_recipients) if parent
    r
  end

  def transitive_collaborators
    r = []
    r.concat(collaborators) if collaborators
    r.concat(parent.transitive_collaborators) if parent
    r.uniq {|c| c.user.to_param }
  end

  def collaborating_users
    r = transitive_collaborators.collect {|c| c.user }
    r << owner if owner
    r
  end

  def add_content_to_zipfile_at_path(zipfile, path)
    children.each do |child|
      prefix = path.blank? ? "#{name}/" : "#{path}/#{name}/"
      if child.type == 'Document'
        zipfile.add("#{prefix}#{child.name}", child.latest_version.content.to_file)
      else
        child.add_content_to_zipfile_at_path(zipfile, "#{prefix}")
      end
    end
  end

  def regenerate_node_images
    node_images.each {|n| n.destroy }
    children.each do |child|
      if child.can_generate_node_image?
        Rails.logger.info "generating node image for #{child.to_param}: #{child.display_name}"
        begin
          ni = node_images.build
          ni.media = Paperclip.io_adapters.for(child.latest_version.content)
          ni.save!
          Rails.logger.info "generating node image done for #{child.to_param}"
        rescue Exception => e
          Rails.logger.info "ERROR while generating node images for #{child.to_param}: #{e}"
        end
      end
    end
  end

  def can_generate_node_image?
    return false unless type == 'Document'
    return false if latest_version.blank?
    return latest_version.content.content_type.start_with?('image')
  end

  def primary_node_image
    # TODO: just the first for now
    return nil if node_images.blank?
    return node_images.first
  end

  def primary_image_url
    return nil unless primary_node_image
    primary_node_image.media.url(:original)
  end

  def thumb_url
    return nil if primary_node_image.blank?
    return primary_node_image.media.url(:thumb)
  end

  def vote_average
    if vote_count > 0
      vote_sum / vote_count
    else
      0
    end
  end

  def voted_by(user, vote)
    UserToNode.get(user, self).has_voted(vote)
    propagate_votes_up()
  end

  def user_has_voted(user)
    user && UserToNode.get(user, self).voted
  end

  def propagate_votes_up
    # determine votes on self
    votes = { :count => 0, :sum => 0 }
    user_to_nodes.all.select { |u2n| u2n.voted }.each do |u2n|
      votes[:count] += 1
      votes[:sum] += u2n.vote
    end

    # also sum up votes on children
    children.all.each do |child|
      votes[:count] += child.vote_count
      votes[:sum] += child.vote_sum
    end

    # save the aggregated votes
    self.vote_count = votes[:count]
    self.vote_sum = votes[:sum]
    self.save!

    # recurse up the tree
    parent.propagate_votes_up() if parent
  end

  private

  def check_storage_limit(user, additional_bytes)
    limit = SimpleConfig.storage_limit
    used = user.documentspace_used_in_bytes
    if used + additional_bytes > limit
      raise "Your storage limit is exceeded. Limit is #{limit / 1024}kB, you are using #{used / 1024}kB already."
    end
  end
end
