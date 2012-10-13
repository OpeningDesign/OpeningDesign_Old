require 'spec_helper'

describe LinkedinRegistrationsController do

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "POST 'create'" do
    it "fails without auth data" do
      post 'create', { :user => { :email => FactoryGirl.generate(:email) }}
      response.status.should == 400
    end
    describe "with auth data" do
      it "succeeds" do
        session['devise.linkedin_data'] = Hashie::Mash.new({
          :extra => { :raw_info => {
            :firstName => 'Hans',
            :lastName => 'Meier',
            :id => '1234'
          }}
        })
        post 'create', { :user => { :email => FactoryGirl.generate(:email) }}
        response.status.should == 302
      end
    end
  end

end
