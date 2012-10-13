module LoginMacros
  #  TODO: should be provided by devise test helpers?
  def sign_in(user)
    visit root_path
    if example.metadata[:js]
      page.driver.browser.execute_script "$('.tooltip.signin').show();"
    end
    click_link "Sign in"
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"
  end
  def user_signs_in_and_creates_project
    @project = FactoryGirl.create(:project)
    @owner = @project.owner
    sign_in @owner
  end
end
