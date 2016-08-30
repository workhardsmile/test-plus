# == Schema Information
#
# Table name: project_operation_system_configs
#
#  project_id :integer
#  operation_system_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class ProjectOperationSystemConfig < ActiveRecord::Base
  belongs_to :project
  belongs_to :operation_system
end
