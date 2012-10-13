require 'spec_helper'

describe "Landings" do
  describe "when landing for the first time" do
    it "display a welcome message (maybe not?)" do
      visit root_path
      page.should have_content("OpeningDesign")
    end
  end
  describe "when signed in" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
    let(:user) { @user }
    it "should display the user name" do
      visit root_path
      page.should have_content(user.name)
    end
    it "should have a link to the profile" do
      visit root_path
      click_link user.name
      page.should have_content("My profile")
    end
  end
  describe "when a project has been created" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
    it "should display an activity about who created the project when" do
      @project_name = "This is a new project"
      visit new_project_path
      fill_in :name, with: @project_name
      fill_in 'project_description', with: "This is the description"
      choose 'project_explicitly_open_sourced_true'
      click_button :commit
      visit root_path
      page.should have_content(@user.name + " created")
      page.should have_content(@project_name)
    end
  end

end
