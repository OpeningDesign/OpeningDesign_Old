require 'spec_helper'

describe "documents/_document.html.erb" do

  before(:each) do
    @document = FactoryGirl.create(:document, :owner => FactoryGirl.create(:user) )
  end

  it "renders the name" do
    render :handlers => [:erb], :partial => 'documents/document', :formats => [:html], :locals => { :document => @document }
    rendered.should match /#{@document.name}/
  end

end
