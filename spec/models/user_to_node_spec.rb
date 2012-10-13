require 'spec_helper'

describe UserToNode do
  before(:each) do
    @user = FactoryGirl.create(:user)
  end
  describe "when voting on single node" do
    before(:each) do
      @node = FactoryGirl.create(:node)
    end
    it "is zero initially" do
      @node.vote_average.should eq(0)
      @node.vote_count.should eq(0)
    end
    it "reflects a single vote" do
      @node.voted_by(@user, 123)
      @node = Node.find(@node.id)
      @node.vote_count.should eq(1)
      @node.vote_average.should eq(123)
    end
    it "reflects two votes" do
      @user2 = FactoryGirl.create(:user)
      @node.voted_by(@user, 100)
      @node.voted_by(@user2, 50)
      @node.vote_average.should eq(75)
      @node.vote_count.should eq(2)
    end

    describe "when having tree with 3 levels" do
      # a helper
      def add_3_children(node)
        (1..3).each do
          node.children << FactoryGirl.create(:node)
        end
      end
      before(:each) do
        add_3_children(@node)
        add_3_children(@node.children[0])
        # this gives us:
        # @node
        # +- child 1
        #    +- grand child 1
        #    +- grand child 2
        #    +- grand child 3
        # +- child 2
        # +- child 3
      end
      it "propagates up the node tree" do
        @node.children[0].children[0].voted_by(@user, 100)
        @node.vote_average.should eq(100)
        @node.vote_count.should eq(1)
      end
      it "propagates multiple votes up the node tree" do
        @node.children[0].children[0].voted_by(@user, 100)
        @node.children[1].voted_by(@user, 80)
        @node.children[2].voted_by(@user, 60)
        @node.voted_by(@user, 40)
        @node.vote_average.should eq(70)
        @node.vote_count.should eq(4)
      end
    end
  end
end
