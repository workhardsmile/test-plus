class TestRoundMailer < AsyncMailer
  default :from => "TestPlus <demo_db@163.com>", :content_type => "text/html"
  # send email to creator and script owners when test round is finished.
  def finish_mail(test_round_id)
    @test_round = TestRound.find(test_round_id)
    #send email only when test type in BVT or Regression
    if ['BVT','Regression'].index @test_round.test_type.name
      @project = @test_round.project
      mail_to = []
      #if @test_round.test_type.name == 'BVT'
      mail_to = @project.mail_notify_settings.map(&:mail)
      #end
      mail_to << @test_round.creator.email unless @test_round.creator.email == 'automator@testplus.com'
      mail_to += @test_round.owner_emails
      mail_to << 'gang.wu@istuary.com'     
      mail_to = mail_to.map{|n| n.downcase}.uniq.join(',')
      subject = "[#{@project} #{@test_round.test_suite.test_type.name}##{@test_round.id} on #{@test_round.test_environment.name}] #{@test_round.result} : for testing #{@test_round.test_object}"
      send_mail(mail_to, subject)
    end
  end

  def notify_mail(test_round_id,reveivers_string)
    @test_round = TestRound.find(test_round_id)
    @project = @test_round.project
    @test_services = @test_round.automation_script_results.collect{|asr| asr.target_services}.flatten.join(', ')
    subject = "[Report for #{@project} #{@test_round.test_suite.test_type.name}##{@test_round.id} on #{@test_round.test_environment.name} ] #{@test_round.result} : for testing #{@test_round.test_object}"
    send_mail(reveivers_string, subject)
  end

  protected
  def send_mail(to, subject)
    logger.info "send mail to #{to}, with subject: #{subject}"
    mail(:to => to,
         :subject => subject
         ) unless to.empty?
  end

end
