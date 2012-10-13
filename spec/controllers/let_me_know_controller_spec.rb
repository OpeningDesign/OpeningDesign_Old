require 'spec_helper'

describe LetMeKnowController do

  describe "posting from a form" do

    def post_form_data(recipient)
      post 'create', { name: recipient.name, email: recipient.email }
    end

    it "should be successful" do
      recipient = FactoryGirl.build(:let_me_know_recipient)
      post_form_data(recipient)
      last_email.to.should include recipient.email
      last_email.bcc.should include 'ryan@openingdesign.com'
      last_email.bcc.should include 'chris.oloff@alacrity.co.za'
      LetMeKnowRecipient.all.count.should eq(1)
    end

    it "should also be successful if same email used again" do
      recipient = FactoryGirl.build(:let_me_know_recipient)
      LetMeKnowRecipient.all.count.should eq(0)
      post_form_data(recipient)
      last_email.to.should include recipient.email
      LetMeKnowRecipient.all.count.should eq(1)
      post_form_data(recipient)
      LetMeKnowRecipient.all.count.should eq(1)
    end

  end

  #describe "viewing all who posted to the form" do
  #  pending "we need the concept of an admin / operator for users first"
  #end

end
