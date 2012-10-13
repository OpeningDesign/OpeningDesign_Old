class CollaborationRequestMailer < ActionMailer::Base
  default :from => SimpleConfig.no_reply_email
  layout 'mailer_layout'

  def request_invite(request)
    @name = request.user.name
    @owner = request.node.owner
    @node = request.node
    @node_url = url_for(@node)
    @message = request.message
    mail(:to => [ @node.owner.email ],
         :subject => "OpeningDesign: #{@name} wants to be a collaborator on #{@node.display_name}",
         :bcc => [ 'chris.oloff@alacrity.co.za' ])
  end
end
