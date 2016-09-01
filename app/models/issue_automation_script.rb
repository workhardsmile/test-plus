class IssueAutomationScript < ActiveRecord::Base  
  belongs_to :project
  belongs_to :issue
  delegate :issue_display_id, :to => :issue, :prefix => false
  delegate :issue_summary, :to => :issue, :prefix => false
  delegate :issue_url, :to => :issue, :prefix => false
  delegate :reporter, :to => :issue, :prefix => false
  def set_attributes_from_hash_params(issue_automation_script_params)
    self.project_id = issue_automation_script_params[:project_id] unless issue_automation_script_params[:project_id].nil?
    self.issue_id = issue_automation_script_params[:issue_id] unless issue_automation_script_params[:issue_id].nil?
    self.automation_script_name = issue_automation_script_params[:automation_script_name] unless issue_automation_script_params[:automation_script_name].nil?
    self.found_case_id = issue_automation_script_params[:found_case_id] unless issue_automation_script_params[:found_case_id].nil?
    self.found_environment = issue_automation_script_params[:found_environment] unless issue_automation_script_params[:found_environment].nil?
    self.found_os_type = issue_automation_script_params[:found_os_type] unless issue_automation_script_params[:found_os_type].nil?
    self.found_browser = issue_automation_script_params[:found_browser] unless issue_automation_script_params[:found_browser].nil?
  end
end
