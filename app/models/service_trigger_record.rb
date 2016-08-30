class ServiceTriggerRecord < ActiveRecord::Base
  attr_accessible :project_id, :project_mapping_name, :status, :test_round_id, :test_environment, :test_suite_id
  belongs_to :project
  validates_presence_of :project_id, :project_mapping_name, :status, :test_round_id, :test_environment, :test_suite_id
end
