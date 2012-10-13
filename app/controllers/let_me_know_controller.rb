class LetMeKnowController < ApplicationController

  def create
    LetMeKnowRecipient.handle_posted_form(params)
    if params[:redirect_to].blank?
      head :ok
    else
      redirect_to params[:redirect_to]
    end
  end

end
