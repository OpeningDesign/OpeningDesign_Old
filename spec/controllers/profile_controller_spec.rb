require 'spec_helper'

describe ProfileController do

  describe "GET 'show'" do
    describe "if not signed in" do
      it "redirects to the sign in" do
        subjects = [ lambda { get :show } ] # there'll be more later, probably
        subjects.each do |subject|
          subject.call.should redirect_to(new_user_session_path)
        end
      end
    end

    describe "if signed in" do

      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      let(:user) { @user }

      it "should be successful" do
        get 'show'
        response.should be_success
      end
    end
  end

end
