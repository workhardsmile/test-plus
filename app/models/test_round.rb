# == Schema Information
#
# Table name: test_rounds
#
#  id                  :integer         not null, primary key
#  start_time          :datetime
#  end_time            :datetime
#  state               :string(255)
#  result              :string(255)
#  test_object         :string(255)
#  pass                :integer
#  warning             :integer
#  failed              :integer
#  not_run             :integer
#  pass_rate           :float
#  duration            :integer
#  triage_result       :string(255)
#  test_environment_id :integer
#  project_id          :integer
#  creator_id          :integer
#  test_suite_id       :integer
#  created_at          :datetime
#  updated_at          :datetime
#

class TestRound < ActiveRecord::Base
  include CounterUpdatable
  belongs_to :test_environment
  belongs_to :browser
  belongs_to :operation_system
  belongs_to :project
  belongs_to :test_suite
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :automation_script_results

  delegate :automation_case_count, :to => :test_suite, :prefix => false
  delegate :test_type, :to => :test_suite, :prefix => false

  acts_as_audited :protect => false
  # acts_as_audited :protect => false, :only => [:create, :destroy]

  validates_presence_of :test_object,:branch_name

  def to_s
    "#{self.test_type.name} ##{self.id}"
  end

  def find_automation_scirpt_by_script_name(script_name)
    self.test_suite.automation_scripts.find_by_name(script_name)
  end

  def set_default_value
    self.state = "scheduling"
    self.result = 'pending'
    self.pass = 0
    self.warning = 0
    self.failed = 0
    self.not_run = 0
  end

  def clear
    self.end_time = nil
    self.state = "scheduling"
    self.result = "pending"
    self.duration = nil
    self.pass = pass_count
    self.failed = failed_count
    self.warning = warning_count
    self.not_run = not_run_count
    calculate_pass_rate!
    self.exported_status = "N"
    self.save
  end

  def self.create_for_new_build(test_suite, project, test_environment, user, test_object, browser, os, branch_name, parameter,enable_auto_rerun)
    test_round = TestRound.new
    test_round.set_default_value
    test_round.test_suite = test_suite
    test_round.creator = user
    test_round.project = project
    test_round.test_object = test_object
    test_round.test_environment = test_environment
    test_round.browser = browser
    test_round.operation_system = os
    test_round.branch_name = branch_name
    test_round.parameter = parameter
    if enable_auto_rerun == "on"
      test_round.counter = 3
    end
    test_round.save
    test_round
  end

  def init_automation_script_result
    test_suite.automation_scripts.each do |as|
      AutomationScriptResult.create_from_test_round_and_automation_script(self, as)
    end
    self.not_run = not_run_count
    save
  end

  def end?
    ["not implemented","service error","completed"].include? self.state
  end

  def fail?
    result == 'failed'
  end

  def all_automation_script_results_finished?
    automation_script_results.all?{|asr| asr.end?}
  end

  def update_start_time
    self.start_time = self.automation_script_results.collect{|asr| asr.start_time.nil? ? Time.now : asr.start_time}.min
  end

  def exported_to_testlink?
    self.exported_status == 'Y'
  end
  def start_running!
    unless running?
      self.state = 'running'
      # update_start_time
    end
  end

  def end_running!
    if running?
      calculate_result!
      self.end_time = Time.now
      calculate_duration!
      calculate_pass_rate!
      calculate_result!
      self.exported_status ='N'
    end
  end

  def scheduling?
    self.state == "scheduling"
  end

  def running?
    self.state == "running"
  end

  def calculate_result!
    if automation_script_results.all?{|asr| asr.passed?}
      self.state = 'completed'
      self.result = 'pass'
    else
      self.state = 'completed'
      self.result = 'failed'
    end
  end

  def calculate_duration!
    self.duration = end_time - start_time
  end

  def pass_count
    self.automation_script_results.sum(:pass)
  end

  def failed_count
    self.automation_script_results.sum(:failed)
  end

  def warning_count
    self.automation_script_results.sum(:warning)
  end

  def not_run_count
    self.automation_script_results.sum(:not_run)
  end

  def count_test_case_by_condition(conditions = {})
    {"pass" => self.automation_script_results.where(conditions).sum(:pass),
     "failed" => self.automation_script_results.where(conditions).sum(:failed),
     "not_run" => self.automation_script_results.where(conditions).sum(:not_run)
     }
  end

  def calculate_pass_rate!
    if automation_case_count == 0
      0.0
    else
      self.pass_rate = (pass_count.to_f * 100)/ automation_case_count
      self.pass_rate.round(2)
    end
  end

  def update_state!
    service_triggr_record = ServiceTriggerRecord.find_by_test_round_id(self.id)
    if all_automation_script_results_finished?
      end_running!
      service_triggr_record.update_attributes(status: 'done') if service_triggr_record
    else
      start_running!
      service_triggr_record.update_attributes(status: 'running') if service_triggr_record      
    end
    save
  end

  def send_triage_mail?
    self.automation_script_results.any?{|asr| asr.result != 'pass' and asr.triage_result == "N/A"}
  end

  def update_result
    if automation_script_results.any?{|asr| ["Product Error","Environment Error"].include? asr.triage_result}
      self.result = 'failed'
    else
      self.result = 'pass'
    end
    save
  end

  def find_automation_script_result_by_script_name(script_name)
    automation_script = self.test_suite.automation_scripts.find_last_by_name(script_name)
    self.automation_script_results.find_last_by_automation_script_id(automation_script.id)
  end

  def get_result_details
    result_array =[]
    self.automation_script_results.each do |asr|
      script_name = asr.name
      test_plan = asr.automation_script.test_plan
      test_plan_name = test_plan.name
      service_info = ''
      asr.target_services.each {|t| service_info<<t.to_s if t}
      asr.automation_case_results.each do |acr|
        temp = Hash.new
        temp['case_name']=acr.name
        temp['case_id']=acr.case_id
        temp['test_link_id']=test_plan.test_cases.find_by_case_id(acr.case_id).test_link_id
        temp['result']=acr.result
        temp['script_name'] = script_name
        temp['test_plan_name'] = test_plan_name
        temp['service_info'] = service_info
        result_array << temp
      end
    end
    result_array
  end

  def count_test_round_result!
    self.pass = pass_count
    self.failed = failed_count
    self.warning = warning_count
    self.not_run = not_run_count
    self.save
  end

  def owner_emails
    emails = []
    query_string = "select DISTINCT a.owner_id from automation_scripts a
      join automation_script_results asr on asr.automation_script_id = a.id
      where asr.test_round_id = '#{self.id}'"
    AutomationScript.find_by_sql(query_string).each {|as| emails << as.owner.email}
    return emails
  end

  def notification_emails
    self.project.mail_notify_settings.map(&:mail)
  end

  def auto_rerunable_scripts
    self.automation_script_results.select{|asr| (asr.counter < self.counter) and (asr.result != 'pass') and (asr.error_type_id ==nil)}
  end

  def get_test_result_hash
    result={}
    self.automation_script_results.each do |asr|
      error_type = asr.error_type_id.nil? ? nil : asr.error_type.name
      asr.automation_case_results.each do |acr|
        result["#{acr.automation_case.case_id}"]={
      "script_name" => asr.name,
        "result" => acr.result,
        "error_type" => error_type,
        "triage_result" => asr.triage_result
      }
      end
    end
    result
  end

  def triage_result_analysis
    result = Hash.new
    ErrorType.where(:result_type=>"pass").each do |error_type|
      result[error_type.name]=self.automation_script_results.where(:error_type_id=>error_type.id).map{|i| i.all_count}.inject(0, :+)
    end
    result
  end

end
