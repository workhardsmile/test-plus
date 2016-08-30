class TestPlansController < InheritedResources::Base
  respond_to :js
  belongs_to :project

  protected
  def resource
    @project ||= Project.find(params[:project_id])
    @test_plan ||= TestPlan.find(params[:id])
    @search = @test_plan.test_cases.search(params[:search])
    @test_cases = @search.page(params[:page]).per(15)
  end

  def collection
    @project ||= Project.find(params[:project_id])
    @search = @project.test_plans.search(params[:search])
    @test_plans ||= @search.page(params[:page]).per(15)
  end
end
