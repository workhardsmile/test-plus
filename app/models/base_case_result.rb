class BaseCaseResult < ActiveRecord::Base
  belongs_to :base_script_result
  belongs_to :base_case_result

  def update_result_from_acr(automation_case_result)
    if automation_case_result
      self.automation_case_result_id = automation_case_result.id
      self.case_name = automation_case_result.automation_case.name
      self.test_result = automation_case_result.result
      self.error_message = automation_case_result.error_message
      self.save!
    end
  end

  def screen_shots
    AutomationCaseResult.find(self.automation_case_result_id).screen_shots
  end
end
