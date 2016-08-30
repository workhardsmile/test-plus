# == Schema Information
#
# Table name: suite_selections
#
#  test_suite_id        :integer
#  automation_script_id :integer
#  created_at           :datetime
#  updated_at           :datetime
#

class SuiteSelection < ActiveRecord::Base
  belongs_to :test_suite
  belongs_to :automation_script
  
end
