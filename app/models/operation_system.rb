class OperationSystem < ActiveRecord::Base
  has_many :project_operation_system_configs
  has_many :projects, :through => :project_operation_system_configs

  validates_presence_of :name, :version
  validates_uniqueness_of :version, :scope => :name

  def name_with_version
    "#{name}, #{version}"
  end
end
