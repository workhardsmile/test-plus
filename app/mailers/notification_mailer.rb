class NotificationMailer < ActionMailer::Base
  default :from => "TestPlus <demo_db@163.com>", :content_type => "text/html"

    def save_to_testlink_notification(email_address,message,test_round_id,tl_project_name)    
    @message  = message
    @tl_project_name = tl_project_name
    mail(to: email_address, subject: "[TestRound-#{test_round_id}] saving result to #{tl_project_name} in Testlink")
  end

end
