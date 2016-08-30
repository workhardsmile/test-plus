# == Schema Information
#
# Table name: automation_cases
#
#  id                   :integer         not null, primary key
#  name                 :string(255)
#  case_id              :string(255)
#  version              :string(255)
#  priority             :string(255)
#  automation_script_id :integer
#  created_at           :datetime
#  updated_at           :datetime
#

class AutomationCase < ActiveRecord::Base
  belongs_to :automation_script
  has_many :automation_case_results
end
