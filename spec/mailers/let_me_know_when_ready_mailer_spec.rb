require "spec_helper"

describe LetMeKnowWhenReadyMailer do
  it "should have access to URL helpers" do
    lambda { projects_url }.should_not raise_error
  end
end
