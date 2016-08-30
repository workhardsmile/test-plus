class Admin::OperationSystemsController < InheritedResources::Base
  layout "admin"
  before_filter :authenticate_user!
  load_and_authorize_resource

  def create
    create!{admin_operation_systems_url}
  end

  def update
    update!{admin_operation_systems_url}
  end
end
