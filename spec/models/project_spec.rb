require 'spec_helper'

describe Project do
  it "requires a unique name" do
    p1 = FactoryGirl.create(:project)
    p2 = FactoryGirl.create(:project)
    p2.name = p1.name
    p2.save().should eq(false)
    p2.should have(1).error_on(:name)
  end

  it "creates sub projects within projects" do
    @user = FactoryGirl.create(:user)
    @parent = FactoryGirl.create(:project, :owner_id => @user.id)
    @sub_project = Project.create_by_user(@user, FactoryGirl.attributes_for(:project, :parent_id => @parent.id))
    @sub_project.owner.should eq(@user)
    @sub_project.parent.should eq(@parent)
  end

  describe "Popularity" do

    before(:each) do
      @project = FactoryGirl.create(:project)
      @now = Time.now
      Time.stub!(:now).and_return(@now)
    end

    def advance_time_by(howmuch)
      @now = @now + howmuch
      Time.stub!(:now).and_return(@now)
    end

    it "has score of 0 initially" do
      Node.update_popularity_scores
      Project.find(@project.id).popularity_score.should be_within(0.01).of(0.0)
    end

    it "has score of 1 when there is a current activity" do
      activity = FactoryGirl.create(:user_creates_project, :target => @project)
      Node.update_popularity_scores
      Project.find(@project.id).popularity_score.should be_within(0.01).of(1.0)
    end

    it "has score of 0.5 when there is a single activity that decayed 50%" do
      activity = FactoryGirl.create(:user_creates_project, :target => @project)
      advance_time_by(Node.decay_to_zero_duration / 2)
      Node.update_popularity_scores
      Project.find(@project.id).popularity_score.should be_within(0.01).of(0.5)
    end

  end

end
