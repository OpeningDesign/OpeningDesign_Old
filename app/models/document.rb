class Document < Node

  acts_as_connectable verbs: []

  validates_uniqueness_of :name, :scope => :parent_id

  # TODO: the following should be removed, we use has_attached_file on DocumentVersion, only
  #has_attached_file :file_content, :path => SimpleConfig.paperclip_path

  scope :by_parent_and_name, lambda {|parent, name| where("parent_id = ? and name = ?",
                                                          parent.id, name)}

  def self.create_by_user(user, params)
    document = Document.new(params)
    document.owner = user
    if document.save
      Activities.spout_activities_for_user_action(user, :creates, document, {
        :template => 'activities/user_creates_document',
        :display_name => user.display_name
      })
    end
    document
  end

  def self.compare(a, b)
    a.name <=> b.name
  end

  def icon_name
    'file'
  end

  def latest_version
    Node.document_versions(self).max { |a,b| a.version <=> b.version }
  end

  def version
    latest_version.version
  end

  def size
    latest_version.content.size
  end

  def downloads_count
    Node.document_versions(self).reduce(0) { |sum, v| sum += v.downloads_count } rescue 0
  end

  def thumb_url
    return nil unless latest_version
    return latest_version.content.expiring_url(60, :thumb) if latest_version.image?
    return icon_for(latest_version.content_file_name)
  end

  def icon_for(filename)
    ext = filename.match(/[.](\w{1,6})\Z/)[1] rescue 'warning'
    "/file_icons/#{ext}.png"
  end

end
