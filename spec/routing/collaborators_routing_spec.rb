require "spec_helper"

describe CollaboratorsController do
  describe "routing" do

    before(:each) do
      # Could be any node
      @node = FactoryGirl.create(:project)
    end

    it "routes to #index" do
      get("/nodes/#{@node.to_param}/collaborators").should route_to("collaborators#index", :node_id => @node.to_param)
    end

    it "routes to #new" do
      get("/nodes/#{@node.to_param}/collaborators/new").should route_to("collaborators#new", :node_id => @node.to_param)
    end

    it "routes to #show" do
      get("/nodes/#{@node.to_param}/collaborators/1").should route_to("collaborators#show", :node_id => @node.to_param, :id => "1")
    end

    it "routes to #edit" do
      pending
    end

    it "routes to #create" do
      pending
    end

    it "routes to #destroy" do
      pending
    end

  end
end
