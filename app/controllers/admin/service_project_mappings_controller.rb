class Admin::ServiceProjectMappingsController < InheritedResources::Base
  layout 'admin'
  before_filter :authenticate_user!
  load_and_authorize_resource

  def create
    create!{admin_service_project_mappings_url}
  end

  def update
    update!{admin_service_project_mappings_url}
  end

end
