require 'spec_helper'

describe UsersController do

  describe "when not logged in" do
    it "certain actions redirect to the sign in" do
      subjects =
        lambda { get :index },
        lambda { get :show, :id => FactoryGirl.create(:user).id },
        lambda { get :edit, :id => FactoryGirl.create(:user).id },
        lambda { delete :destroy, :id => FactoryGirl.create(:user).id }
      subjects.each do |subject|
        subject.call.should redirect_to(new_user_session_path)
      end
    end
  end

  describe "when logged in" do
    before(:each) do
      @a_user = FactoryGirl.create(:user)
      sign_in FactoryGirl.create(:user)
    end
    describe "and when not an operator" do
      it "redirects to the home page for some actions" do
        get(:index).should redirect_to(root_path)
        get(:edit, :id => 1).should redirect_to(root_path)
        get(:destroy, :id => 1).should redirect_to(root_path)
        put(:update, :id => 1).should redirect_to(root_path)
      end
      it "allows viewing a user" do
        get(:show, :id => @a_user.id)
        assigns(:user).should eq(@a_user)
      end
    end
    describe "and when an operator" do
      before(:each) do
        sign_in FactoryGirl.create(:user, :operator => true)
      end
      it "allows to view all users" do
        get :index
        assigns(:users).should eq(User.all)
      end
      it "allows to edit a user" do
        get :edit, :id => @a_user.id.to_s
        assigns(:user).should eq(@a_user)
      end
      it "allows to update a user" do
        attribs = { "any" => 'attributes' }
        User.should_receive(:find).and_return(@a_user)
        @a_user.should_receive(:update_attributes).with(attribs)
        put :update, :id => @a_user.id.to_s, :user => attribs
      end
    end
  end

end
