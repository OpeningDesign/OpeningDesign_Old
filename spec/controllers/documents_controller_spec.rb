require 'spec_helper'

describe DocumentsController do

  before(:each) do
    Authorization.ignore_access_control(true)
  end

  describe "when user is signed in" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    describe "GET 'new'" do
      it "should be successful" do
        get 'new', :parent_id => FactoryGirl.create(:project).id
        response.should be_success
      end
    end

    describe "POST 'create'" do
      it "should be successful" do
        project = FactoryGirl.create(:project)
        expect {
          document = FactoryGirl.attributes_for(:document_in_project, :parent_id => project.id)
          post 'create', :document => document
        }.to change(Document, :count).by(1)
      end
    end

    describe "GET 'download'" do
      it "should download the document" do
        document_version = FactoryGirl.create(:document_version)
        DocumentVersion.any_instance.stub(:content) do
          o = Object.new
          o.instance_eval do
            def to_file
              File.join(Rails.root, "/spec/support/testfile.txt")
            end
            def content_type
              "text/html"
            end
          end
          o
        end
        get 'download', :id => document_version.parent.to_param
        response.should be_success
      end
    end

    describe "GET 'edit'" do
      it "should be successful" do
        doc = FactoryGirl.create(:document_in_project)
        get 'edit', :id => doc.id
        response.should be_success
      end
    end

    describe "GET 'update'" do
      it "should be successful" do
        get 'update', :id => FactoryGirl.create(:document_in_project).id
        response.should be_success
      end
    end

    describe "GET 'destroy'" do
      before(:each) do
        request.env["HTTP_REFERER"] = "/"
      end
      it "should be successful" do
        delete 'destroy', :id => FactoryGirl.create(:document_in_project, :owner => @user).id
        response.should redirect_to "/"
      end
    end

  end

  describe "GET 'show'" do
    it "should be successful" do
      doc = FactoryGirl.create(:document_in_project)
      get 'show', :id => doc.id.to_s
      response.should be_success
    end
  end

end
