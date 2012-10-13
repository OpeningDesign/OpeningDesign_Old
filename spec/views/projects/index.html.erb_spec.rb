require 'spec_helper'

describe "projects/index.html.erb" do

  before(:each) do
    now = Time.now
    @projects = []
    (1..10).each do |n|
      project = FactoryGirl.create(:project, :updated_at => now)
      project.owner.stub(:profile_pic_url) { "http://fake-profilepic.com/user-#{n}" }
      @projects << project
    end
    view.stub(:current_user) { @projects[0].owner }
    assign(:projects, @projects)
  end

  it "renders a list of projects" do
    render
    (1..10).each do |n|
      assert_select "ul li:nth-child(#{n})" do
        project = @projects[n-1]
        assert_select "*", /#{project.name}/
        assert_select "*", /#{project.description[0..10]}/ # description is truncated in the view
        assert_select "a img[src=\"#{project.owner.profile_pic_url}\"]"
      end
    end
  end
end
