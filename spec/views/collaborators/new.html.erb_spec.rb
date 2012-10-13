require 'spec_helper'

describe "collaborators/new" do
  before(:each) do
    assign(:collaborator, stub_model(Collaborator).as_new_record)
  end

  it "renders new collaborator form" do
    pending
    render :handlers => [:erb]

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => collaborators_path, :method => "post" do
    end
  end
end
