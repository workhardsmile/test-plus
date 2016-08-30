# == Schema Information
#
# Table name: automation_scripts
#
#  id                   :integer         not null, primary key
#  name                 :string(255)
#  status               :string(255)
#  version              :string(255)
#  test_plan_id         :integer
#  owner_id             :integer
#  project_id           :integer
#  created_at           :datetime
#  updated_at           :datetime
#  automation_driver_id :integer
#  time_out_limit       :integer
#

class AutomationScript < ActiveRecord::Base
  DEFAULT_TIME_OUT_LIMIT= 7200
  belongs_to :test_plan
  belongs_to :project
  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  has_many :automation_cases
  has_many :suite_selections
  has_many :test_suites, :through => :suite_selections
  belongs_to :automation_driver_config
  acts_as_ordered_taggable
  def find_case_by_case_id(case_id)
    self.automation_cases.find_by_case_id(case_id)
  end
end
