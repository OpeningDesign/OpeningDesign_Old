require 'spec_helper'

describe "collaborators/show" do
  before(:each) do
    @collaborator = assign(:collaborator, stub_model(Collaborator))
  end

  it "renders attributes in <p>" do
    pending
    render :handlers => [:erb]
  end
end
