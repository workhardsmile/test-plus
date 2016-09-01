class BaseScriptResultsController < InheritedResources::Base
  respond_to :js
  belongs_to :project

  protected
  def resource
    @automation_script_result = nil
    @automation_script_result = AutomationScriptResult.find(params[:automation_script_result_id]) unless params[:automation_script_result_id].nil?
    @project ||= Project.find(params[:project_id])
    @base_script_result ||= BaseScriptResult.find(params[:id])
    @search = @base_script_result.base_case_results.search(params[:search])
    @base_case_results = @search.page(params[:page]).per(15)
    @base_case_results.sort!{|bcr1, bcr2| bcr1.automation_case_display_id <=> bcr2.automation_case_display_id}
  end

  def collection
    @project ||= Project.find(params[:project_id])
    @search = @project.base_script_results.search(params[:search])
    @base_script_results ||= @search.order('id desc').page(params[:page]).per(15)
  end
end
