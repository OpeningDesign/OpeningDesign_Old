require 'spec_helper'

describe "Projects" do

  describe "when not logged in" do
    it "requires me to sign in / up when creating a project" do
      # TODO: this is a brittle way of verifying that you are redirected to login
      # we should probably just not test this here, as the projects_controller_spec
      # tests this without the rendering?
      visit root_path
      click_link "Create a Space"
      page.should have_content "You need to sign in or sign up"
      page.should have_no_content "New project"
    end
  end

end

