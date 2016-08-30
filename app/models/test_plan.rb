# == Schema Information
#
# Table name: test_plans
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  status     :string(255)
#  version    :string(255)
#  project_id :integer
#  created_at :datetime
#  updated_at :datetime
#

class TestPlan < ActiveRecord::Base
  has_many :test_cases
  has_many :automation_scripts
  belongs_to :project
end
