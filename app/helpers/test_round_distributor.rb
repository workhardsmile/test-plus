class TestRoundDistributor
  @queue = :testplus_farm

  def self.perform(test_round_id)
    test_round = TestRound.find(test_round_id)
    test_round.test_suite.automation_scripts.each do |as|
      AutomationScriptResult.create_from_test_round_and_automation_script(test_round, as)
    end
    test_round.not_run = test_round.automation_script_results.sum(:not_run)
    test_round.save!
    test_round = TestRound.find(test_round_id)
    on_master_branch = (test_round.branch_name == 'master')
    unless on_master_branch
      existing_branch_scripts = ProjectBranchScript.where(:project_id => test_round.project_id, :branch_name => test_round.branch_name).map(&:automation_script_name)
    end
    test_round.automation_script_results.each do |asr|
      unless asr.automation_script.status == 'Completed'
        asr.error_type_id = ErrorType.find_by_name("Not Ready").id
        asr.triage_result = asr.automation_script.note
        asr.result = "failed"
        asr.state = "not implemented"
        asr.save
        next
      end

      if on_master_branch or existing_branch_scripts.index(asr.automation_script.name)
        sa = SlaveAssignment.create!
        sa.automation_script_result = asr
        sa.status = "pending"
        sa.browser_name = test_round.browser.name
        sa.browser_version = test_round.browser.version
        sa.operation_system_name = test_round.operation_system.name
        sa.operation_system_version = test_round.operation_system.version
        sa.save!

        # besides saving it to db, we need to save sa to redis, too.
        # farm server will query redis instead of db to get the latest sa status
        SlaveAssignmentsHelper.send_slave_assignment_to_list sa, :pending
      else
        # mark automation script result as failed
        # set triage result to Not in Branch
        asr.error_type_id = ErrorType.find_by_name("Not in Branch").id
        asr.triage_result = "this script is not in current branch"
        asr.result = "failed"
        asr.state = "not implemented"
        asr.save
      end
    end
  end

  def self.distribute(test_round_id)
    Resque.enqueue(TestRoundDistributor, test_round_id)
  end

end
