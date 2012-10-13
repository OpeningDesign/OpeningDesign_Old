require File.expand_path("../../../config/environment", __FILE__)

namespace :odb do
  desc "Process activities since last digest email and send next digest emails for all users"
  task :digest_emails do |t|
    DailyDigestMailer.prepare_and_mail_all
  end
end
