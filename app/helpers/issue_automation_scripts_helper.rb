module IssueAutomationScriptsHelper
  def self.get_issue_automation_script_params_from_asr(automation_script_result,case_id=nil)
    params = nil
    if automation_script_result
      params = Hash.new
      params[:found_environment]=automation_script_result.test_round.test_environment.name
      params[:found_os_type]=automation_script_result.test_round.operation_system.name
      params[:found_browser]=automation_script_result.test_round.browser.name
      params[:automation_script_name]=automation_script_result.name
      params[:found_case_id]=case_id
      params[:project_id]=automation_script_result.test_round.project_id
    end
    params
  end

  def self.create_or_update_from_issue_automation_script_params(issue_automation_script_params)
    begin
      @issue_automation_script = IssueAutomationScript.find_or_create_by_issue_id_and_automation_script_name_and_project_id(issue_automation_script_params[:issue_id],issue_automation_script_params[:automation_script_name],issue_automation_script_params[:project_id])
      @issue_automation_script.set_attributes_from_hash_params(issue_automation_script_params)
      @issue_automation_script.save!
      @issue_automation_script
    rescue =>e
    #puts e
    false
    end
  end

  def self.get_slice_text_from_text_by_length(text,length=30)
    if text and text.length >= length
      text = text.slice(0,length).concat("...")
    end
    text
  end
  
  def self.string_is_empty?(text_string)
    if "#{text_string}".strip==""
      return true
    end
    false
  end
end
