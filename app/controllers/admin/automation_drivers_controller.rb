class Admin::AutomationDriversController < InheritedResources::Base

  layout 'admin'
  before_filter :authenticate_user!
  load_and_authorize_resource

  def create
    create!{admin_automation_drivers_url}
  end

  def update
    update!{admin_automation_drivers_url}
  end

end
