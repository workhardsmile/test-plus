# == Schema Information
#
# Table name: ci_mappings
#
#  id            :integer         not null, primary key
#  project_id    :integer
#  test_suite_id :integer
#  ci_value      :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class CiMapping < ActiveRecord::Base
  belongs_to :project
  belongs_to :test_suite
  belongs_to :browser
  belongs_to :operation_system

  validates_presence_of :ci_value, :test_suite, :browser, :operation_system
  validates_uniqueness_of :ci_value, :scope => :project_id, :message => "already exists."
end
