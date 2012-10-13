class LetMeKnowRecipient < ActiveRecord::Base

  validates :email, :name, presence: true
  validates :email, uniqueness: true

  def self.handle_posted_form(params)
    params = params.select { |key,_| attribute_names.include? key }
    LetMeKnowWhenReadyMailer.let_me_know(params['name'], params['email']).deliver
    existing = find_by_email(params['email'])
    if existing.blank?
      LetMeKnowRecipient.create!(params)
    else
      existing.update_attributes(params)
      existing.save
    end
  end

end
