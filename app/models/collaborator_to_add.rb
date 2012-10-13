class CollaboratorToAdd
  attr_accessor :name_or_email
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  def persisted?
    false
  end

  def initialize(params)
    self.name_or_email = params[:name_or_email]
  end

end
