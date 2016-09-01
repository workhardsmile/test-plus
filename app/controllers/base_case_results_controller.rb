class BaseCaseResultsController < InheritedResources::Base
  respond_to :js
  belongs_to :base_script_result

  def resource
    @base_script_result ||= BaseScriptResult.find(params[:base_script_result_id])
    @base_case_result ||= BaseCaseResult.find(params[:id])
    @project = @base_script_result.project
  end
  
  def collection
    @base_script_result ||= BaseScriptResult.find(params[:base_script_result_id])
    @search = @base_script_result.base_case_results.search(params[:search])
    @base_case_results ||= @search.page(params[:page]).per(15)
  end
end
