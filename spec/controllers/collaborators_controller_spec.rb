require 'spec_helper'

describe CollaboratorsController do

  before(:each) do
    @node = FactoryGirl.create(:project) # Could be any node
  end

  describe "when the owner is signed in" do
    before(:each) do
      @owner = @node.owner
      sign_in @owner
      @users = []; 2.times { @users << FactoryGirl.create(:user) }
    end
    it "POST create, without name or email" do
      post(:create, :node_id => @node.to_param).should redirect_to(node_collaborators_path(@node))
    end
    it "POST create, with invalid name or email" do
      post(:create, :node_id => @node.to_param, :collaborator_to_add => { :name_or_email => 'sldkfjhasldfgkjh'}).should redirect_to(node_collaborators_path(@node))
    end
    it "POST create, with valid email or valid name" do
      [ @users[0].email, @users[1].name ].each do |name_or_email|
        expect do
          post :create, :node_id => @node.to_param, :collaborator_to_add => { :name_or_email => name_or_email }
        end.to change { Collaborator.find_all_by_node_id(@node.to_param).count } .by(1)
      end
    end
    it "POST create, for the same user twice" do
      expect do
        2.times do
          post :create, :node_id => @node.to_param, :collaborator_to_add => { :name_or_email => @users[0].email }
        end
      end.to change { Collaborator.find_all_by_node_id(@node.to_param).count } .by(1)
    end
    it "POST create, with a user_id" do
      expect do
        post :create, :node_id => @node.to_param, :user_id => @users[0].to_param
      end.to change { Collaborator.find_all_by_node_id(@node.to_param).count }.by(1)
    end
    describe "when there are collaborators" do
      before(:each) do
        @users.each do |user|
          @node.collaborators.build(:user => user).save!
        end
      end
      it "PUT delete" do
        expect do
          put :destroy, :node_id => @node.to_param, :id => @node.collaborators[0].to_param
        end.to change { Collaborator.find_all_by_node_id(@node.to_param).count }.by(-1)
      end
      it "GET index" do
        get :index, { :node_id => @node.to_param }
        assigns(:collaborators).should eq(@node.collaborators)
      end
    end

  end

  describe "when somebody (not the owner) is logged in" do
    before(:each) do
      @owner = @node.owner
      @logged_in_user = FactoryGirl.create(:user)
      sign_in @logged_in_user
      @users = []; 2.times { @users << FactoryGirl.create(:user) }
      @users.each do |user|
        @node.collaborators.build(:user => user).save!
      end
    end
    describe "PUT delete" do
      it "is rejected" do
        expect do
          put :destroy, :node_id => @node.to_param, :id => @node.collaborators[0].to_param
        end.to change { Collaborator.find_all_by_node_id(@node.to_param).count }.by(0)
      end
    end

  end

  describe "GET index" do
    it "assigns all collaborators as @collaborators" do
      get :index, { :node_id => @node.to_param}
      assigns(:collaborators).should eq([])
    end
  end

  describe "POST create, not logged in" do
    it "should fail and redirect" do
      @user = FactoryGirl.create(:user)
      post :create, :node_id => @node.to_param, :collaborator_to_add => { :name_or_email => @user.email }
      response.should redirect_to(new_user_session_path)
    end
  end

  describe "DELETE destroy, not signed in" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @node.collaborators.build(:user => @user).save!
    end
    it "should fail as unauthorized" do
      put :destroy, :node_id => @node.to_param, :id => @node.collaborators[0].to_param
      response.should redirect_to(new_user_session_path)
    end
  end

end
