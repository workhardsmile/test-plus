class AutomationScriptResultsInitializer
  @queue = :testplus_farm

  def self.perform(test_round_id)
    test_round = TestRound.find(test_round_id)
    test_round.test_suite.automation_scripts.each do |as|
      AutomationScriptResult.create_from_test_round_and_automation_script(test_round, as)
    end
    test_round.not_run = test_round.automation_script_results.sum(:not_run)
    test_round.save
  end

  def self.createAutomationScriptResults(test_round_id)
    Resque.enqueue(AutomationScriptResultsInitializer, test_round_id)
  end

end
