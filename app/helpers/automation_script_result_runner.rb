class AutomationScriptResultRunner
  @queue = :testplus_farm

  def self.perform(automation_script_result_id)

    sa = SlaveAssignment.find_by_automation_script_result_id(automation_script_result_id)
    if sa
      # sa.status = "pending"
      sa.reset!
      sa.save

    else
      test_round = AutomationScriptResult.find(automation_script_result_id).test_round
      sa = SlaveAssignment.create!
      sa.automation_script_result_id = automation_script_result_id
      sa.status = "pending"
      sa.browser_name = test_round.browser.name
      sa.browser_version = test_round.browser.version
      sa.operation_system_name = test_round.operation_system.name
      sa.operation_system_version = test_round.operation_system.version
      sa.save!
    end
    # besides saving it to db, we need to save sa to redis, too.
    # farm server will query redis instead of db to get the latest sa status
    SlaveAssignmentsHelper.send_slave_assignment_to_list sa, :pending
  end

  def self.rerun(automation_script_result_id)
    Resque.enqueue(AutomationScriptResultRunner, automation_script_result_id)
  end
end
