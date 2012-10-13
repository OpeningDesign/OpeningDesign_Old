require 'spec_helper'

describe Collaborator do
  describe 'given a root node with some children' do
    before(:each) do
      @owner = FactoryGirl.create(:user)
      @guest = FactoryGirl.create(:user)
      @root = FactoryGirl.create(:project, :owner => @owner)
      (1..5).each do
        @root.children << FactoryGirl.create(:project,
                                             :owner => FactoryGirl.create(:user),
                                             :parent => @root)
      end
    end
    describe "when the guest is a collaborator on the root" do
      before(:each) do
        @root.collaborators.create(:user_id => @guest.id)
      end
      it "notifies the guest when the owner adds another collaborator" do
        another_collaborator = FactoryGirl.create(:user)
        @root.collaborators.create(:user_id => another_collaborator.id)
        SocialConnections.aggregate(@guest).activities.select {|a| a.target == another_collaborator }.size.should eq(1)
      end
    end
    it "the owner of a node is a collaborator on the node and all its children" do
      @root.collaborator?(@owner).should eq(true)
      @root.children.each do |child|
        child.collaborator?(@owner).should eq(true)
      end
      @collaborator = FactoryGirl.create(:user)
      @root.collaborators.create(:user_id => @collaborator.id)
      @root.collaborator?(@collaborator).should eq(true)
    end
    it "a guest is no owner (also not of any child, unless the child is owned by the guest)" do
      @root.children << FactoryGirl.create(:node, :name => 'owned by guest', :owner => @guest)

      @root.collaborator?(@guest).should eq(false)
      @root.children.each do |child|
        should_be_owner = child.name == 'owned by guest'
        child.collaborator?(@guest).should eq(should_be_owner)
      end
    end
    it "considers the guest a collaborator on any node if guest is collaborating on the root node" do
      @root.collaborators.build(:user_id => @guest.id)
      @root.collaborator?(@guest).should eq(true)
      @root.children.each do |child|
        child.collaborator?(@guest).should eq(true)
      end
    end
  end
end
