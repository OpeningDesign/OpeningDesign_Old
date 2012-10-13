require 'zip/zip'

class Project < Node

  validates_presence_of :name, :owner
  validates_uniqueness_of :name, :scope => :parent_id
  validates :description, :length => { :maximum => 140 }

  scope :root_projects_of_user, lambda{|user| where "owner_id = ? and parent_id is NULL", user.id }
  scope :root_projects, where("parent_id is NULL")

  acts_as_connectable :verbs => [], :additional_recipients => :determine_additional_recipients

  def writable_by?(user)
    return false if user.blank?
    return user.id == owner.id
  end

  def self.create_by_user(user, params, parent_id = nil)
    project = Project.new(params)
    project.owner = user
    project.parent = Node.find(parent_id) if parent_id
    if project.save
      Activities.spout_activities_for_user_action(user, :creates, project, {
        :template => 'activities/user_creates_project',
        :display_name => user.display_name
      })
    end
    project
  end

  def icon_name
    'folder-open'
  end

  def collapsed_in_view_default
    false
  end

  def display_name
    typename = self.parent ? I18n.t("sub_project") : I18n.t("project")
    "#{typename} \"#{name.truncate(60)}\""
  end

  def create_temporary_zipfile
    filename = "#{`mktemp tmp/zipped_project_XXXXXXX`}".strip + ".zip"
    ::Zip::ZipFile.open(filename, ::Zip::ZipFile::CREATE) do |zf|
      add_content_to_zipfile_at_path(zf, '')
    end
    `chmod +r #{filename}`
    return File.new(filename)
  end

end
