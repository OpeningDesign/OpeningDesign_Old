
class Activities < ActiveRecord::Base

  acts_as_connectable verbs: []

  def self.aggregated
    SocialConnections.aggregate(Activities.instance).activities
  end

  def self.instance
    if Activities.all.count == 0
      Activities.create
    end
    Activities.first
  end

  def self.clear
    aggregated.each { |a| a.consume }
  end

  # treats closed-source correctly, AS LONG as you cannot go from open to closed:
  # The 'instance' would always be connected to a once-open node, thus we'd
  # always generate activities that are publicly visible.
  def self.spout_activities_for_user_action(user, activity, target, options)
    if open_source?(target) && !instance.connected_to?(target)
      instance.connect_to(target)
    end
    user.send(activity, target, options)
  end

  private
  # a target for an activity is open source if it's a node (that responds to :is_open_source),
  # or it's open source anyway otherwise.
  def self.open_source?(target)
    return target.is_open_source if target.respond_to?(:is_open_source)
    return true
  end

end

