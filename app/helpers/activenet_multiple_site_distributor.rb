class ActivenetMultipleSiteDistributor
  @queue = :testplus_farm

  def self.perform(params)
    project = Project.find_by_name('ActiveNet')
    params["site_names"].split(',').uniq.each do |site|
      test_round = project.test_rounds.build
      test_round.set_default_value
      test_round.test_environment_id = params["test_environment_id"]
      test_round.test_suite_id = params["test_suite_id"]
      test_round.browser_id = params["browser_id"]
      test_round.operation_system_id = params["operation_system_id"]
      test_round.assigned_slave_id = params["assigned_slave_id"]
      test_round.creator_id = params["creator_id"]
      test_round.test_object = "#{site.upcase} - #{params['test_object']}"
      test_round.parameter = site
      test_round.branch_name = params['branch_name']
      test_round.counter = params['counter']
      test_round.save!
      distribute_test_round(test_round.id)
    end
  end

  def self.distribute_test_round(test_round_id)
    test_round = TestRound.find(test_round_id)
    test_round.test_suite.automation_scripts.each do |as|
      AutomationScriptResult.create_from_test_round_and_automation_script(test_round, as)
    end
    test_round.not_run = test_round.automation_script_results.sum(:not_run)
    test_round.save!
    test_round = TestRound.find(test_round_id)
    test_round.automation_script_results.each do |asr|
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
    end
  end

  def self.distribute(params)
    Resque.enqueue(ActivenetMultipleSiteDistributor, params)
  end

end
