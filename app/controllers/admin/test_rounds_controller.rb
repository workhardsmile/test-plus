class Admin::TestRoundsController < InheritedResources::Base
  belongs_to :project
  respond_to :js
  layout 'admin'
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def create
    project = Project.find(params[:project_id])
    test_object = params[:test_round][:test_object].strip
    test_objects = project.test_rounds.find_all_by_test_object(test_object)
    if test_objects.length > 0 then
      flash[:error] = test_object + " already exists"
      render :action => "new" and return
    end

    params[:test_round][:test_object] = params[:test_round][:test_object].strip
    super
  end
  
  protected
  def resource
    @project ||= Project.find(params[:project_id])
    @test_round ||= TestRound.find(params[:id])
  end

  def collection
    @project ||= Project.find(params[:project_id])
    @search = @project.test_rounds.search(params[:search])
    @admin_test_rounds ||= @search.order('id desc').page(params[:page]).per(15)
  end
end
