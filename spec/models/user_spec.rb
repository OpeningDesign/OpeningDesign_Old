require 'spec_helper'

describe User do
  it "does allow the same user name again" do
    user = FactoryGirl.create(:user)
    User.create(first_name: user.first_name, last_name: user.last_name,
               email: 'tom@gmail.com', password: 'whateva').should have(0).errors
  end
  it "finds users by name" do
    user = FactoryGirl.create(:user)
    User.find_by_name(user.name).name.should eq(user.name)
  end
  it "does not allow the same email again" do
    user = FactoryGirl.create(:user)
    User.create(first_name: "Some", last_name: "Body",
                email: user.email, password: 'something secret').should have(1).error_on(:email)
  end
  it "gives no operator status for normal users" do
    user = FactoryGirl.create(:user)
    user.operator?.should be(false)
  end

  it "allows operator status to be set for normal users" do
    user = FactoryGirl.create(:user)
    user.operator?.should be(false)
    user.operator = true
    user.operator?.should be(true)
  end

  it "gives predefined email addresses operator status" do
    ryan = FactoryGirl.create(:user, email: 'ryan@openingdesign.com')
    ryan.operator?.should be(true)
    chris = FactoryGirl.create(:user, email: 'chris.oloff@alacrity.co.za')
    chris.operator?.should be(true)
  end

  describe "profile pictures" do
    it "users without any auth provider id have a gravatar url" do
      u = FactoryGirl.create(:user)
      u.gravatar_pic?.should be(true)
    end
    it "when having a facebook id, the pic is not a gravatar one" do
      u = FactoryGirl.create(:user, :facebook_id => '123')
      u.gravatar_pic?.should be(false)
    end
  end

  describe "subscription level" do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end
    describe "default subscription level" do
      it "allows 1 closed node" do
        @user.number_closed_nodes_left.should eq(1)
        FactoryGirl.create(:project, :owner => @user, :explicitly_open_sourced => true)
        # having created (thus owning) an open source project doesn't make a difference
        @user.number_closed_nodes_left.should eq(1)
      end
      it "allows no more closed nodes, once one has been created" do
        FactoryGirl.create(:project, :owner => @user, :explicitly_open_sourced => false)
        @user.number_closed_nodes_left.should eq(0)
      end
    end
    describe "other subscription levels" do
    end
  end
end
