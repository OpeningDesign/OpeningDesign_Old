class Sketchspace < Node
  acts_as_connectable :verbs => []
  validates_uniqueness_of :name, :scope => :parent_id

  before_create do |s|
    s.pad_id = SecureRandom.hex(30)
  end

  def self.create_by_user(user, params)
    ss = Sketchspace.new(params)
    ss.owner = user
    if ss.save
      Activities.spout_activities_for_user_action(user, :creates, ss, {
        :template => 'activities/user_creates_sketchspace',
        :display_name => user.display_name
      })
    end
    ss
  end

  def self.guess_pad_id(sketchspace_url)
    # match the last word, without any parameters that might be in the url
    sketchspace_url.match(/(\w+)(\?.+)?$/)[1]
  end

  def determine_show_url(user)
    if collaborator?(user) || ( is_open_source && user )
      path = "#{pad_id}?createImmediately=true"
    else
      path = "ep/pad/view/#{determine_readonly_pad_id}/latest"
    end
    "#{SimpleConfig.sketchspace_base_url}/#{path}"
  end

  def determine_readonly_pad_id
    return cached_readonly_pad_id if cached_readonly_pad_id
    uri = URI("#{SimpleConfig.sketchspace_base_url}/ep/rwtoro?id=#{pad_id}")
    Rails.logger.info "URI=#{uri}"
    response = Net::HTTP.get uri
    Rails.logger.info "response=#{response}"
    ro_id = JSON.parse(response)["readOnlyId"]
    self.cached_readonly_pad_id = ro_id
    save
    ro_id
  end

  def icon_name
    'comment'
  end
end
