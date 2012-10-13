require 'spec_helper'

describe "When users have deleted their account" do

  before(:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe "when users have created and updated a project" do
    before(:each) do
      project_attribs = Factory.attributes_for(:project)
      @changed_project_name = "#{project_attribs[:name]} (Changed)"
      @project = Project.create_by_user(@user, project_attribs)
      @project.update_by_user(@user, project_attribs.merge(:name => @changed_project_name))
      @user.destroy
    end
    it "should show activities, with the name of the user, no link to the user and a link to the project" do
      visit root_path
      page.should have_content @user.display_name
      page.should have_no_link(@user.display_name)
      page.should have_link("Project \"#{@project.name}\"")
    end
  end
end
