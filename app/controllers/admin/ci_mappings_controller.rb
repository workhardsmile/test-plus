class Admin::CiMappingsController < InheritedResources::Base
  belongs_to :project
  layout 'admin'
  before_filter :authenticate_user!
  load_and_authorize_resource

  def create
    create!{admin_project_ci_mappings_url(@project)}
  end

  def update
    update!{admin_project_ci_mappings_url(@project)}
  end

end
