class AutomationCaseResultsController < InheritedResources::Base
  respond_to :js
  belongs_to :automation_script_result

  def resource
    @automation_script_result ||= AutomationScriptResult.find(params[:automation_script_result_id])
    @automation_case_result ||= AutomationCaseResult.find(params[:id])
    @test_case = TestCase.find_by_case_id(@automation_case_result.automation_case.case_id)
    @project = @automation_script_result.test_round.project
  end
  
  def collection
    @automation_script_result ||= AutomationScriptResult.find(params[:automation_script_result_id])
    @search = @automation_script_result.automation_case_results.search(params[:search])
    @automation_case_results ||= @search.page(params[:page]).per(15)
  end
end
