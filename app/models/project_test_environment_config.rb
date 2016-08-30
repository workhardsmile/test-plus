class ProjectTestEnvironmentConfig < ActiveRecord::Base
  belongs_to :project
  belongs_to :test_environment
end
