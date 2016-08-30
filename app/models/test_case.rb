# == Schema Information
#
# Table name: test_cases
#
#  id               :integer         not null, primary key
#  name             :string(255)
#  case_id          :string(255)
#  version          :string(255)
#  automated_status :string(255)
#  priority         :string(255)
#  test_plan_id     :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class TestCase < ActiveRecord::Base
  belongs_to :test_plan
  has_many :tc_steps
end
