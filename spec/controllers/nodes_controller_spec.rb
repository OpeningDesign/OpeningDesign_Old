require 'spec_helper'

describe NodesController do

  before(:each) do
    @project = FactoryGirl.create(:project) # it could be any node
  end

  describe "when not signed in" do
    it "redirects to the sign in " do
      [ :subscribe, :unsubscribe ].each do |action|
        post(action, :node_id => @project.id).should redirect_to(new_user_session_path)
      end
      # TODO: inconsistent routes, here it's :id, before it's :node_id
      post(:upload, :id => @project.id).should redirect_to(new_user_session_path)
    end
  end

  describe "when signed in" do
    before(:each) do
      @user = @project.owner
      sign_in @user
      stub!(:current_user).and_return(@user)
    end

    def uploadable_file_name
      'document1.odt'
    end
    def uploadable_file
      fixture_file_upload(File.join(Rails.root, "/spec/support/#{uploadable_file_name}"))
    end
    def uploadable_file_as_param
      { :content => [ uploadable_file ] }
    end
    def uploadable_files_as_param(n = 3)
      { :content => n.times.reduce([]) { |a,i| a << uploadable_file } }
    end

    it "allows uploading a file for a project" do
      expect {
        post :upload, :id => @project.id,
           :document_version => uploadable_file_as_param
      }.to change { Project.find(@project.to_param).children.count }.by(1)
    end
    it "allows uploading many files for a project" do
      expect {
        post :upload, :id => @project.id,
           :document_version => uploadable_files_as_param(5)
      }.to change { Project.find(@project.to_param).children.count }.by(5)
    end
    it "allows uploading a new version for a document" do
      d = FactoryGirl.create(:document, :parent => @project)
      expect {
        post :upload, :id => d.id, :document_version => uploadable_file_as_param, :new_version_only => true
      }.to change { Document.find(d.to_param).children.count }.by(1)
      child = Document.find(d.to_param).children[0]
      child.should be_kind_of(DocumentVersion)
      child.version.should eq(1)
      child.name.should eq(uploadable_file_name)
      Document.find(d.to_param).name.should eq(d.name)
      expect {
        post :upload, :id => d.id, :document_version => uploadable_file_as_param, :new_version_only => true
      }.to change { Document.find(d.to_param).children.count }.by(1)
      d.version.should eq(2)
    end
    it "allows uploading a second version for a document" do
      d = FactoryGirl.create(:document, :parent => @project)
      expect {
        post :upload, :id => d.id, :document_version => uploadable_file_as_param,
             :new_version_only => true
        name = d.name
        post :upload, :id => d.id, :document_version => uploadable_file_as_param,
             :new_version_only => true
        d.name.should eq(name)
      }.to change { d.children.count }.by(2)
    end
    it "allows uploading a document under a document" do
      d = FactoryGirl.create(:document, :parent => @project)
      expect {
        post :upload, :id => d.id, :document_version => uploadable_file_as_param, :multipart => :true
      }.to change { Document.find(d.to_param).children.count }.by(1)
      child = Document.find(d.to_param).children[0]
      child.should be_kind_of(Document)
    end
    it 'subscribes and unsubscribes the current user' do
      current_user.connected_to?(@project).should be_false
      post :subscribe, :node_id => @project.to_param
      current_user.connected_to?(@project).should be_true
      post :unsubscribe, :node_id => @project.to_param
      current_user.connected_to?(@project).should be_false
    end

    describe "moving nodes" do
      before(:each) do
        @new_parent = FactoryGirl.create(:project, :description => "should be the new parent project")
        @child_of_project = FactoryGirl.create(:project, :parent => @project, :description => "child of project")
      end
      it "allows a user to move a node to a new parent" do
        request.env['HTTP_REFERER'] = "http://test.com/bla" # we just need an arbitrary referer
        post :move, :node_id => @project.to_param
        post :submitmove, :node_id => @new_parent.to_param
        @project = Node.find(@project.to_param)
        @project.parent.should eq(@new_parent)
      end
      it "marks the node images as dirty when moved" do
        request.env['HTTP_REFERER'] = "http://test.com/bla" # we just need an arbitrary referer
        post :move, :node_id => @child_of_project.to_param
        post :submitmove, :node_id => @new_parent.to_param
        @project = Node.find(@project.to_param)
        @project.node_images_dirty.should eq(true)
        @new_parent = Node.find(@new_parent.to_param)
        @new_parent.node_images_dirty.should eq(true)
      end
      it "prevents moving to itself or a child of itself" do
        request.env['HTTP_REFERER'] = "http://test.com/bla" # we just need an arbitrary referer
        post :move, :node_id => @project.to_param
        expect {
          post :submitmove, :node_id => @project.to_param
        }.to raise_error
        expect {
          post :submitmove, :node_id => @child_of_project.to_param
        }.to raise_error
      end
    end
  end

end
