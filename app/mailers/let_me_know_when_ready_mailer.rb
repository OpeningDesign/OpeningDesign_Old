class LetMeKnowWhenReadyMailer < ActionMailer::Base
  default from: SimpleConfig.no_reply_email
  layout 'mailer_layout'

  def let_me_know(name, email)
    @name = name
    mail(to: [ email ], subject: 'Hello from OpeningDesign.com',
         bcc: [
           'ryan@openingdesign.com',
           'chris.oloff@alacrity.co.za'])
  end
end
