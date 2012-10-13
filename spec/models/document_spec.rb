require 'spec_helper'

describe Document do

  before(:each) do
    @user = FactoryGirl.create(:user)
  end

  # TODO: probably we don't need this: documents typically created by uploading, and then
  # we create a new document via NodesController#upload, right?
  it "creates documents for users" do
    params = FactoryGirl.attributes_for(:document)
    params[:parent] = FactoryGirl.create(:project)
    doc = Document.create_by_user(@user, params)
    doc.name.should eq(params[:name])
    doc.owner.should eq(@user)
  end

  include ActionDispatch::TestProcess

  describe "can create thumbnail image for parent" do
    before(:each) do
      @project = FactoryGirl.create(:project, :owner => @user)
      dv_attrs = FactoryGirl.attributes_for(:uploadable_document_version,
                                          :parent_id => @project.id)
      params = { :content => [ fixture_file_upload(File.join(Rails.root, '/spec/support/document1.odt'))]}
      @text_doc = @project.upload_documents_by_user(@user, @project, params)[0]
    end

    it "does not create an image for a text doc" do
      @text_doc.latest_version.should_not be_nil
      @project.regenerate_node_images
      @project.node_images.should be_empty
    end

    describe "when there is an image" do
      before(:each) do
        params = { :content => [ fixture_file_upload(File.join(Rails.root, 'spec/support/sample.jpg'), 'image/jpg')]}
        puts "content.class=#{params[:content][0].class}"
        @image_doc = @project.upload_documents_by_user(@user, @project, params)[0]
      end
      it "creates an image for an image doc" do
        @project.regenerate_node_images
        @project.node_images.count.should be(1)
        image = @project.node_images[0]
        image.media.url(:thumb).should_not be_empty
        image.media.url(:medium).should_not be_empty
      end
    end
  end
end
