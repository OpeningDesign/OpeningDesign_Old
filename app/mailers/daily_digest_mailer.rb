class DailyDigestMailer < ActionMailer::Base
  include ApplicationHelper
  helper :application
  default :from => SimpleConfig.no_reply_email
  layout 'mailer_layout'

  def prepare_and_mail_all
    log "starting daily digest emails"
    User.all.each do |user|
      feed = SocialConnections.aggregate(user)
      activities = feed.activities.select {|a| a.unseen && a.subject.id != user.id }
      next if activities.blank?
      log "Email #{user.name} (#{user.email}) #{activities.count} activities"
      @user = user
      @activities = activities.sort {|a,b| a.created_at <=> b.created_at }
      email = mail(:to => user.email,
                   :bcc => 'chris.oloff@alacrity.co.za',
                   :subject => I18n.t("daily_digest.subject",
                                      :default => "OpeningDesign: %{count} activities you might be interested in",
                                      :count => activities.count))
      email.deliver
      @activities.each do |activity|
        activity.consume
      end
    end
    log "finished daily digest emails"
  end

  private

  def log(*args)
    Rails.logger.info(*args)
  end

end
