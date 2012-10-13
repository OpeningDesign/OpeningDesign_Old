class DocumentVersion < Node
  acts_as_connectable :verbs => []
  has_attached_file :content,
    :styles => { :medium => "360x360>", :thumb => "32x32>" },
    :path => "/contents/:id/:style/:filename",
    :storage => :s3,
    :s3_credentials => Odr::Application.s3_credentials,
    :bucket => SimpleConfig.s3_bucket,
    :s3_permissions => 'private',
    :s3_protocol => 'https',
    :s3_headers => {"Content-Disposition" => "attachment"},
    :whiny => false

  after_create do |dv|
    surrounding_project.update_column :node_images_dirty, true
  end

  before_destroy do |dv|
    surrounding_project.update_column :node_images_dirty, true
  end

  def self.compare(a, b)
    b.version <=> a.version
  end

  def display_name
    "#{name} (version #{version})"
  end

  def icon_name
    'map-marker'
  end

  def latest_version?
    version == parent.version
  end

  def surrounding_project
    containing_document.parent if containing_document
  end

  def containing_document
    parent
  end

  def image?
    # TODO: probably not good enough, see image method here:
    # https://github.com/thoughtbot/paperclip/wiki/Extracting-image-dimensions
    content.content_type =~ /^image/
  end

end
