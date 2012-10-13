require 'spec_helper'

describe TwitterRegistrationsController do

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "POST 'create'" do
    it "returns http 302, if auth data given in session" do
      session['devise.twitter_data'] = Hashie::Mash.new({
        :info => { :name => 'Some Name' },
        :uid => "1234" })
      post 'create', { :user => { :email => FactoryGirl.generate(:email) }}
      response.status.should == 302
    end
  end

end
