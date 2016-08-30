class LongTasks
  def distribute_test_round_task(test_round)
    test_round.automation_script_results.each do |asr|
      driver = asr.automation_script.automation_driver.nil? ? 'qtp' : asr.automation_script.automation_driver.to_s

      sa = SlaveAssignment.create
      sa.automation_script_result = asr

      # remove this because we'll assemble the command line string in the automation command
      # sa.command = "#{driver} $#{as.name} $BuildNumber=#{test_round.id} $AUT_ENV=#{test_round.test_environment.value} $MarketName=#{test_round.project.name} $TimeOut=#{time_out_limit}"

      sa.driver = driver
      sa.status = "pending"
      sa.save
    end
  end
  
  def rerun_automation_script_result_task(automation_script_result_id)
    sa = SlaveAssignment.find_by_automation_script_result_id(automation_script_result_id)
    if sa
      sa.status = "pending"
      sa.save
    end
  end

  def send_finish_mail(test_round)
    TestRoundMailer.finish_mail(test_round).deliver
  end

  def send_triage_mail(test_round)
    TestRoundMailer.triage_mail(test_round).deliver
  end
end