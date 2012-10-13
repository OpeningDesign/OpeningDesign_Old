class SubscriptionPlan < ActiveRecord::Base
  # TODO: the following association currently expressed without an AR association, see User#current_subscription
  # has_many :users, :inverse_of => :associated_subscription_plan
  validates_presence_of :name

  def self.plan_names
    ['default', 'tall', 'grande', 'unlimited']
  end

  def larger_than?(other)
    ix_self = SubscriptionPlan.plan_names.index(self.name)
    ix_other = SubscriptionPlan.plan_names.index(other.name)
    return ix_self > ix_other
  end

  def max_number_closed_source_nodes_with_default
    map = { 'default' => 1, 'tall' => 10, 'grande' => 42, 'unlimited' => 999 } # defaults
    result = max_number_closed_source_nodes || map[name]
    result
  end

end
