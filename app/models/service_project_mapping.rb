class ServiceProjectMapping < ActiveRecord::Base
  attr_accessible :project_id, :project_mapping_name, :service_name
  belongs_to :project
  validates_presence_of :project_mapping_name, :service_name
  validates_uniqueness_of :service_name, :scope => :project_id

end
