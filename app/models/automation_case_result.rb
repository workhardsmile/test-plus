# == Schema Information
#
# Table name: automation_case_results
#
#  id                          :integer         not null, primary key
#  result                      :string(255)
#  error_message               :string(255)
#  screen_shot                 :string(255)
#  priority                    :string(255)
#  automation_case_id          :integer
#  automation_script_result_id :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#

class AutomationCaseResult < ActiveRecord::Base
  belongs_to :automation_case
  belongs_to :automation_script_result
  has_many :screen_shots

  delegate :case_id, :to => :automation_case, :prefix => false
  delegate :name, :to => :automation_case, :prefix => false
  delegate :version, :to => :automation_case, :prefix => false

  def set_default_values
    self.result = "not-run"
  end

  def update!(data)
    result_status = 'warning'
    result_status = 'pass' if data['result'].downcase.include? 'pass'
    result_status = 'failed' if data['result'].downcase.include? 'fail'
    self.result = result_status
    self.error_message = data['error']
    self.screen_shot = data['screen_shot']
    self.save
  end

  def owner
    automation_script_result.automation_script.owner
  end

  def self.create_from_automation_script_result_and_automation_case(automation_script_result, automation_case)
    acr = AutomationCaseResult.new
    acr.set_default_values
    acr.automation_script_result = automation_script_result
    acr.automation_case = automation_case
    acr.priority = automation_case.priority
    acr.save
    acr
  end
  
  def clear
    self.set_default_values
    self.error_message = nil
    self.screen_shot = nil
    self.server_log = nil
    self.save
  end

end
