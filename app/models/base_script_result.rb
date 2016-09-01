class BaseScriptResult < ActiveRecord::Base
  has_many :base_case_results
  belongs_to :project
  def duration
    if start_time && end_time
      end_time - start_time
    else
      nil
    end
  end

  def update_result_from_asr(automation_script_result,is_last=0)
    if automation_script_result
      self.test_result = automation_script_result.result
      self.start_time = automation_script_result.start_time
      self.end_time = automation_script_result.end_time
      self.pass_count = automation_script_result.pass
      self.failed_count = automation_script_result.failed
      self.warning_count = automation_script_result.warning
      self.not_run_count = automation_script_result.not_run
      self.is_latest = is_last
      if is_last == 1
        related_base_scripts = BaseScriptResult.find_all_by_automation_script_name_and_project_id(self.automation_script_name,self.project_id) 
        related_base_scripts ||= []
        related_base_scripts.each do |related_base_script|
          related_base_script.is_latest = 0
          related_base_script.save!
        end
      end
      self.save!
    end
  end
=begin
  def update_triage_result!
    message = ""
    self.base_case_results.where("triage_result != null").order("automation_case_display_id ASC").each{|bcr| message << "#{bcr.automation_case_display_id} -- #{bcr.triage_result}\n"}
    puts message
    self.triage_result =message
    self.save
  end
=end
  def update_triage_result!(message="")
    self.triage_result = message if "#[message]" != ""
    if self.triage_result.starts_with? "Product Error"
      self.test_result = "failed"
    end
    if self.triage_result.starts_with? "Environment Error"
      self.test_result = "failed" 
    end
    if self.triage_result.starts_with?  "Script Error"
      self.base_case_results.each do |tcr|
        tcr.test_result = 'pass'
        tcr.save
      end
      self.test_result = "pass"
    end
    self.save
  end
end
