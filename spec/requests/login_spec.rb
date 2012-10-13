require 'spec_helper'

describe "Logging in" do
  describe "when not logged in" do
    it "allows user to sign up" do
      visit root_path
      click_link "Sign up"
      fill_in "Email", with: 'tom@twain.com'
      fill_in "First name", with: 'Tom'
      fill_in "Last name", with: 'Sawyer'
      fill_in "Password", with: 'secret'
      fill_in "Password confirmation", with: 'secret'
      click_button "Sign up"
      page.should have_content("signed up successfully")
      page.should have_link("Log out")
    end
    it "allows registered user to log in" do
      user = FactoryGirl.create(:user)
      sign_in user
      page.should have_link("Log out")
    end
  end
  describe "when logged in" do
    it "allows user to log out" do
      user = FactoryGirl.create(:user)
      sign_in user
      click_link "Log out"
      page.should have_link("Sign in")
    end
    it "shows the current user's first name" do
      user = FactoryGirl.create(:user)
      sign_in user
      page.should have_content(user.first_name)
    end
  end
end
