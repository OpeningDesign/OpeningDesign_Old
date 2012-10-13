module SocialActivityHelpers
end

RSpec::Matchers.define :equal_social_activity do |expected|
  match do |actual|
    targets_match(actual, expected) &&
      subjects_match(actual, expected) &&
      verbs_match(actual, expected)
  end
  failure_message_for_should do |actual|
    if !targets_match(actual, expected)
      "expected target to be #{expected[:target]}"
    elsif !subjects_match(actual, expected)
      "expected subject to be #{expected[:subject]}, but it was #{actual[:target]}"
    elsif !verbs_match(actual, expected)
      "expected verb to be #{expected[:verb]}, but it was #{actual[:verb]}"
    end
  end

  # whoa... defines methods 'targets_match(actual, expected)', etc.
  [ :target, :subject, :verb ].each do |what|
    define_method "#{what.to_s}s_match" do |actual, expected|
      actual.send(what.to_s) == expected[what]
    end
  end

end

