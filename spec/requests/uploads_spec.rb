require 'spec_helper'

describe "Uploads" do

  describe "when signed in", :js => true do

    before(:each) do
      @project = FactoryGirl.create(:project)
      @user = @project.owner
      sign_in @user
    end

    it "uploads single files" do
      expect {
        visit project_path(@project)
        page.driver.browser.execute_script "$('.tt.project_children').show();"
        attach_file "upload", File.join(::Rails.root, "spec/support/document1.odt")
        page.should have_content('uploaded successfully')
      }.to change { Project.find(@project).children.size }.by(1)
    end

    it "uploads multiple files" do
      expect {
        visit project_path(@project)
        page.driver.browser.execute_script "$('.tt.project_children').show();"
        attach_file "upload", File.join(::Rails.root, "spec/support/document1.odt")
        attach_file "upload", File.join(::Rails.root, "spec/support/document2.odt")
        page.should have_content('uploaded successfully')
        page.should have_content('document1.odt')
        page.should have_content('document2.odt')
      }.to change { Project.find(@project).children.size }.by(2)
    end

    it "uploads file(s) to folders and potentially other nodes" do
      pending "need folders first"
    end

  end

end

