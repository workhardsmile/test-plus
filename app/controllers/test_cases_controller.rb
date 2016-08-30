class TestCasesController < InheritedResources::Base
  respond_to :js
  belongs_to :test_plan

  protected
  def resource
    @test_plan = TestPlan.find(params[:test_plan_id])
    @project = @test_plan.project
    @test_case = TestCase.find(params[:id])
  end

  def collection
    @test_plan = TestPlan.find(params[:test_plan_id])
    @project = @test_plan.project
    @search = @test_plan.test_cases.search(params[:search])
    @test_cases = @search.page(params[:page]).per(15)
  end
end
