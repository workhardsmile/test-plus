# == Schema Information
#
# Table name: test_environments
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  value      :string(255)
#  created_at :datetime
#  updated_at :datetime

class TestEnvironment < ActiveRecord::Base
  has_many :project_test_environment_configs
  has_many :projects, :through => :project_test_environment_configs
  validates_presence_of :name, :value
  validates_uniqueness_of :name, :scope => :name
end
