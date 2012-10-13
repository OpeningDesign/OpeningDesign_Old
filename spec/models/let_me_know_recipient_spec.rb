require 'spec_helper'

describe LetMeKnowRecipient do
  it "requires a name and an email" do
    LetMeKnowRecipient.create(name: 'Joe').should have(1).error_on(:email)
    LetMeKnowRecipient.create(email: 'joe@test.com').should have(1).error_on(:name)
  end
  it "requires email to be unique" do
    LetMeKnowRecipient.create(name: 'Joe', email: 'joe@test.com')
    LetMeKnowRecipient.all.count.should eq(1)
    LetMeKnowRecipient.create(name: 'The same Joe', email: 'joe@test.com').should have(1).
      error_on(:email)
  end
end
