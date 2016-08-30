class FunctionalMailer < ActionMailer::Base
  default :from => "TestPlus <testplus@activenetwork.com>", :content_type => "text/html"

  def endurance_qa_effort(tdate, work_logs)
    @work_logs = work_logs
    subject = "Daily WorkLog for Endurance QA Team #{tdate.strftime('%Y/%m/%d')}"
    mail_to = "phoenix.zhong@activenetwork.com, tyrael.tong@activenetwork.com"
    send_mail(mail_to, subject)
  end

  protected
  def send_mail(to, subject)
    logger.info "send mail to #{to}, with subject: #{subject}"
    mail(:to => to,
         :subject => subject
         ) unless to.empty?
  end

end
