FactoryGirl.define do

  sequence :email do |n|
    "some-email#{n}@test.com"
  end

  factory :user do
    sequence(:email) {|n| "me#{n}@example.com" }
    password 'secret'
    sequence(:first_name) { |n| "Tom #{n}" }
    last_name 'Sawyer'
  end

  factory :let_me_know_recipient do
    sequence(:name) { |n| "Joe #{n}" }
    sequence(:email) { |n| "joe#{n}@test.com" }
  end

  factory :project do
    sequence(:name) { |n| "Project Name #{n}" }
    description "This is a description"
    association :owner, :factory => :user
    explicitly_open_sourced true
  end

  sequence(:random_document_name) do |n|
    "#{(0...20).map{ ('a'..'z').to_a[rand(26)] }.join}.doc"
  end
  factory :document do
    name { FactoryGirl.generate(:random_document_name) }
  end
  factory :document_in_project, :class => Document do
    name "document1.odt"
    file_content_file_name "document1.odt"
    association :parent, :factory => :project
  end
  factory :document_version do
    name { FactoryGirl.generate(:random_document_name) }
    downloads_count 1
    association :parent, :factory => :document_in_project
    association :owner, :factory => :user
    content_file_name "spec/support/file.txt"
  end
  factory :uploadable_document_version, :class => DocumentVersion do
    content File.join(Rails.root, '/spec/support/document1.odt')
  end
  factory :node do
    sequence(:name) do |n|
      "Node #{n}"
    end
    explicitly_open_sourced true
  end
  factory :folder do
    sequence(:name) do |n|
      "Folder #{n}"
    end
    association :parent, :factory => :node
  end
  factory :social_activity do
    unseen true
    association :owner, :factory => :user
    association :subject, :factory => :user
  end
  factory :user_creates_project, :parent => :social_activity do
    verb 'creates'
    association :target, :factory => :project
  end
  factory :user_adds_collaborator, :parent => :social_activity do
    verb 'adds_as_collaborator'
    options_as_json { { :node => FactoryGirl.create(:project) }.to_json }
  end
end

