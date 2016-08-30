# == Schema Information
#
# Table name: automation_script_results
#
#  id                   :integer         not null, primary key
#  state                :string(255)
#  pass                 :integer
#  failed               :integer
#  warning              :integer
#  not_run              :integer
#  result               :string(255)
#  start_time           :datetime
#  end_time             :datetime
#  test_round_id        :integer
#  automation_script_id :integer
#  created_at           :datetime
#  updated_at           :datetime



# Matrix of automation script results
# *Test Result *Script Status    *State Result   *Triage  *Error Type
# PASS         Completed         done            Pass    N/A
# PASS         Completed         done            Pass    Framework Issue
# PASS         Completed         done            Pass    Dynamic Issue
# PASS         Completed         done            Pass    Environment Issue
# PASS         Completed         done            Pass    Product Change
# PASS         Completed         done            Pass    Data Issue
# PASS         Completed         done            Pass    Script Issue
# FAILED       Completed         done            Failed  Product Error
# FAILED       Completed         done            Failed  N/A
# N/A          Known Bug         not implemented Failed  Not Ready
# N/A          Test Data Issue   not implemented Failed  Not Ready
# N/A          Work In Progress  not implemented Failed  Not Ready
# N/A          Disabled          not implemented Failed  Not Ready
# N/A          Completed         not implemented Failed  Not in Branch

class AutomationScriptResult < ActiveRecord::Base
  include CounterUpdatable
  belongs_to :test_round
  belongs_to :automation_script
  belongs_to :error_type
  has_many :automation_case_results
  has_many :target_services
  has_many :slave_assignments
  has_many :slaves, :through => :slave_assignments
  delegate :name, :to => :automation_script, :prefix => false

  def find_case_result_by_case_id(case_id)
    self.automation_case_results.find_by_automation_case_id(case_id)
  end

  def set_default_values
    self.state = "scheduling"
    self.pass = 0
    self.failed = 0
    self.warning = 0
    self.not_run = 0
    self.result = 'pending'
    self.error_type_id = nil
    self.triage_result = 'N/A'
  end

  def self.create_from_test_round_and_automation_script(test_round, automation_script)
    asr = AutomationScriptResult.new
    asr.set_default_values
    asr.test_round = test_round
    asr.automation_script = automation_script

    asr.not_run = automation_script.automation_cases.count
    asr.save

    automation_script.automation_cases.each do |ac|
      AutomationCaseResult.create_from_automation_script_result_and_automation_case(asr, ac)
    end
    asr
  end

  def clear
    self.automation_case_results.each do |acr|
      acr.delete
    end
    self.automation_script.automation_cases.each do |ac|
      AutomationCaseResult.create_from_automation_script_result_and_automation_case(self,ac)
    end
    self.set_default_values
    self.not_run = automation_script.automation_cases.count
    self.start_time = nil
    self.end_time = nil
    self.save
    self.test_round.clear
  end

  def passed?
    self.result == "pass"
  end

  def end?
    ['done','killed','failed','timeout','not implemented','network issue'].include? self.state
  end

  def not_run_cases
    self.automation_case_results.where(:result => "not-run")
  end

  def failed_cases
    self.automation_case_results.where(:result => "failed")
  end

  def update_state!(state)
    self.state = state
    if state == "running"
      self.start_time = Time.now if self.start_time.blank?
    elsif state == "done"
      count_automation_script_and_test_round_result
      self.end_time = Time.now
      self.not_run_cases.each do |automation_case_result|
        automation_case_result.result = 'not-run'
        automation_case_result.save
      end
      if self.not_run > 0
        self.result = 'warning'
      else
        self.result = self.failed > 0 ? 'failed' : 'pass'
      end
      self.counter +=1
    else
      count_automation_script_and_test_round_result
      self.end_time = Time.now
      self.result = 'failed'
      self.counter +=1
    end
    save
  end

  def duration
    if start_time && end_time
      end_time - start_time
    else
      nil
    end
  end

  def pass_count
    self.automation_case_results.where("result='pass'").count
  end

  def failed_count
    self.automation_case_results.where("result='failed'").count
  end

  def warning_count
    self.automation_case_results.where("result='warning'").count
  end

  def not_run_count
    self.automation_case_results.where("result='not-run'").count
  end

  def all_count
    self.automation_case_results.count
  end

  def count_automation_script_result!
    self.pass = pass_count
    self.failed = failed_count
    self.warning = warning_count
    self.not_run = not_run_count
    self.save
  end

  def count_automation_script_and_test_round_result
    if self.end?
      # update script result counting status
      count_automation_script_result!
      # update test round result counting status
      self.test_round.count_test_round_result!
    end
  end

  def save_result_to_baseline
    update_info_to_base_script_result
    self.automation_case_results.each{|acr| acr.update_info_to_base_case_result}
    get_corresponding_base_script_result.update_triage_result!
  end



  def get_related_baseline_script_results
    BaseScriptResult.find_all_by_automation_script_name_and_project_id(self.automation_script.name, self.test_round.project_id)
    count_automation_script_and_test_round_result
  end

  def get_corresponding_base_script_result
    name = self.automation_script.name
    browser = self.test_round.browser.name
    environment = self.test_round.test_environment.name
    os = self.test_round.operation_system.name
    project_id = self.test_round.project_id
    BaseScriptResult.find_or_create_by_automation_script_name_and_browser_and_environment_and_os_type_and_project_id(name,browser,environment,os,project_id)
  end

  def update_info_to_base_script_result
    if self.end?
      bsr = get_corresponding_base_script_result
      bsr.update_result_from_asr(self)
    end
  end

  def is_triage_result_editable?
    self.error_type.result_type != "N/A"    
  end

  def is_rerunnable?
    (not ['pass','pending'].include?(self.result)) or (self.error_type_id != nil)
  end


  def is_in_current_branch?
    test_round = self.test_round
    self.test_round.branch_name == 'master' or ProjectBranchScript.where(:project_id => test_round.project_id, :branch_name => test_round.branch_name, :automation_script_name => self.automation_script.name).count > 0
  end

  def set_to_not_in_branch
    self.error_type_id = ErrorType.find_by_name("Not in Branch").id
    self.triage_result = "this script is not in current branch"
    self.result = "failed"
    self.state = "not implemented"
    self.save
  end

  def set_to_not_ready
    self.error_type_id = ErrorType.find_by_name("Not Ready").id
    self.triage_result = "#{self.automation_script.status.upcase} - #{self.automation_script.note}"
    self.result = "failed"
    self.state = "not implemented"
    self.save
  end

end
