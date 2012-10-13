require 'spec_helper'

describe DocumentVersionsController do

  before(:each) do
    Authorization.ignore_access_control(true)
  end

  describe "GET 'show'" do
    it "should be successful" do
      get 'show', :id => FactoryGirl.create(:document_version).id.to_s
      response.should be_success
    end
  end

end
