class Admin::AutomationDriverConfigsController < InheritedResources::Base

  belongs_to :project
  layout 'admin'
  before_filter :authenticate_user!
  load_and_authorize_resource

  def create

    create!{admin_project_automation_driver_configs_url}
  end

  def update

    params["automation_driver_config"]["source_paths"] = params["source_path"] ? JSON.generate(params["source_path"].values) : nil

    update!{admin_project_automation_driver_configs_url(@project)}
  end

  def destroy

    AutomationScript.find_all_by_automation_driver_config_id(params[:id]).each do |as|
      as.automation_driver_config = nil
      as.save
    end

    destroy!{admin_project_automation_driver_configs_url}
  end

  protected

  def build_resource
    params["automation_driver_config"]["source_paths"] = params["source_path"] ? JSON.generate(params["source_path"].values) : nil if params[:action] == "create"
    super
  end

end
