require 'spec_helper'

describe "activities a guest user should see" do
  describe "when a user signs up" do
    before(:each) do
      FactoryGirl.create(:user)
    end
    it "creates an activity for the guest" do
      Activities.aggregated.count.should eq(1)
    end
  end
  describe 'when a user creates a document in an open source project' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @project = FactoryGirl.create(:project)
      @document_attributes = FactoryGirl.attributes_for(:document, :parent => @project)
    end
    it "creates an activity for the guest" do
      expect {
        Document.create_by_user(@user, @document_attributes)
      }.to change(Activities.aggregated, :count).by(1)
    end
  end
  describe 'when a user creates a document in a closed source project' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @project = FactoryGirl.create(:project, :explicitly_open_sourced => false)
      @document_attributes = FactoryGirl.attributes_for(:document, :parent => @project)
    end
    it "creates no activity for the guest" do
      @project.is_open_source.should be(false)
      @project.incoming_social_connections.count.should be(0)
      expect {
        document = Document.create_by_user(@user, @document_attributes)
        document.incoming_social_connections.count.should be(0)
      }.to change(Activities.aggregated, :count).by(0)
    end
  end
end

