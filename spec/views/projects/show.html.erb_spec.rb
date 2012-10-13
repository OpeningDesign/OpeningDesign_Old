require 'spec_helper'

describe "projects/show.html.erb" do

  before(:each) do
    @project = FactoryGirl.create(:project)
    @document = @project.build_document('A document')
    @document.owner = @project.owner
    @doc_version = FactoryGirl.create(:document_version, :parent => @document) # TODO: doc_version has its own owner
  end

  describe "when logged in" do

    before(:each) do
      view.stub(:current_user) { @project.owner }
    end

    it "renders project actions" do
      render
      rendered.should have_xpath("//a[contains(text(), 'Edit')]")
      rendered.should have_xpath("//a[contains(text(), 'Delete')]")
    end

  end

  describe "when not logged in" do

    before(:each) do
      view.stub(:current_user) { nil }
    end

    it "renders project attributes" do
      render
      rendered.should match(/#{@project.name}/)
      rendered.should match /#{@project.owner.display_name}/
      rendered.should match /#{l @project.updated_at, :format => :short}/
    end

    it "renders the document which is part of the project" do
      render
      rendered.should match(/#{@document.name}/)
      rendered.should match(/#{@document.version}/)
      # TODO: no 'find' in view specs, maybe this helps:
      # http://groups.google.com/group/ruby-capybara/browse_thread/thread/6f8188ba35e170ff
      #rendered.find('.document').should match(/total downloads/)
      # ChrisS likes this, ChrisO not really:
      #rendered.should have_xpath("//span[@class='document node_in_list']//*[contains(text(), 'total downloads')]")
      rendered.should have_xpath("//span[@class='document node_in_list']//*[@class='downloads']")
    end

  end

end
