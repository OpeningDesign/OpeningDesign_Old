require 'spec_helper'

describe "landing/index.html.erb" do
  it "contains the title" do
    @social_activities = []
    @tags = []
    @popular_projects = []
    render
    rendered.should =~ /Most popular projects/
  end
end
