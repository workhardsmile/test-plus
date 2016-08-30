class AutomationProgress < ActiveRecord::Base
  belongs_to :project
  def save_regression_coverage
    @project = self.project
    self.total_case = @project.count_test_case_by_plan_type_and_options('regression',{})
    self.total_automated = @project.count_test_case_by_plan_type_and_options('regression',:automated_status => "Automated")
    self.not_candidate = @project.count_test_case_by_plan_type_and_options('regression',:automated_status => "Not a Candidate")
    self.automatable = @project.count_test_case_by_plan_type_and_options('regression',:automated_status => "Automatable")
    self.not_ready = @project.count_test_case_by_plan_type_and_options('regression',:automated_status => "Not Ready for Automation")
    self.update_manual = @project.count_test_case_by_plan_type_and_options('regression',:automated_status => "Update Needed")
    self.update_needed = @project.count_test_case_by_plan_type_and_options('regression',:automated_status => "Update Manual")    
    self.save
  end

  def unkonwn_cases
    self.total_case - [self.total_automated,self.not_candidate,self.automatable,self.not_ready,self.update_manual,self.update_needed].select{|e| not e.nil? }.sum
  end


end
