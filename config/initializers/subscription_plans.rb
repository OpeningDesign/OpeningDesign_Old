begin
  SubscriptionPlan.plan_names.each do |name|
    SubscriptionPlan.create!(:name => name) unless SubscriptionPlan.find_by_name(name)
  end
rescue
  puts "Unable to update subscription plans: #{$!}"
end
