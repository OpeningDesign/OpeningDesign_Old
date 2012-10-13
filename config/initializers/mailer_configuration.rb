# configure mailer for SMTP
ActionMailer::Base.smtp_settings = {  
  :address              => SimpleConfig.smtp_server,  
  :port                 => SimpleConfig.smtp_port || 25,  
  :domain               => SimpleConfig.smtp_domain,  
  :authentication       => SimpleConfig.smtp_authentication || :plain,  
  :user_name            => SimpleConfig.smtp_user_name,  
  :password             => SimpleConfig.smtp_password,  
  :enable_starttls_auto => SimpleConfig.smtp_enable_starttls_auto || false
}

# configure delivery method
ActionMailer::Base.delivery_method = SimpleConfig.smtp_delivery_method || :smtp



