class AutomationCasesController < InheritedResources::Base
  respond_to :js
  belongs_to :automation_script

  protected
  def resource
    @automation_script ||= AutomationScript.find(params[:automation_script_id])
    @project = @automation_script.project
    @automation_case ||= AutomationCase.find(params[:id])
  end

  def collection
    @automation_script ||= AutomationScript.find(params[:automation_script_id])
    @project = @automation_script.project
    @search = @automation_script.automation_cases.search(params[:search])
    @automation_cases ||= @search.page(params[:page]).per(15)
  end
end
