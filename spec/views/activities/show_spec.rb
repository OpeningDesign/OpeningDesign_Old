require 'spec_helper'

describe "activities" do
  before(:each) do
    @user = FactoryGirl.create(:user)
  end
  describe "user creates project" do
    before(:each) do
      @user_creates_project = FactoryGirl.create(:user_creates_project)
      @user_creates_project_empty_target = FactoryGirl.create(:user_creates_project,
                                                              :target => nil)
    end
    it "renders" do
      render :partial => 'activities/user_creates_project',
        :locals => { :social_activity => @user_creates_project }
      rendered.should =~ /#{@user_creates_project.subject.name}/
      rendered.should =~ /#{@user_creates_project.target.name}/
    end
    it "renders without project" do
      render :partial => 'activities/user_creates_project',
        :locals => { :social_activity => @user_creates_project_empty_target }
      rendered.should =~ /#{@user_creates_project_empty_target.subject.name}/
    end
  end
  describe "user adds collaborator" do
    before(:each) do
      @adds_collaborator_but_node_deleted = FactoryGirl.create(:user_adds_collaborator,
                                                               :options_as_json => { :node => -1 }.to_json )
    end
    it "renders without node" do
      render :partial => 'activities/user_adds_collaborator',
        :locals => { :social_activity => @adds_collaborator_but_node_deleted }
      rendered.should =~ /a node that does not exist/
    end
  end
end
