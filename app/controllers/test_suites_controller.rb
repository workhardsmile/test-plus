class TestSuitesController < InheritedResources::Base
  respond_to :js
  belongs_to :project
  load_and_authorize_resource

  def show
    @search = @test_suite.automation_scripts.search(params[:search])
    @automation_scripts = @search.page(params[:page]).per(15)
    show!{resource_url}
  end

  def create
    create!{collection_url}
  end

  def update
    update!{collection_url}
  end

  def destroy
    destroy!{collection_url}
  end

  def search_automation_script
    project = Project.find(params[:project_id])
    @automation_scripts = project.automation_scripts.order('name asc')
    if params[:search_by_name]
      @automation_scripts = @automation_scripts.where("name LIKE '%#{params[:search_by_name]}%'")
    end
    if params[:search_by_owner] and not params[:search_by_owner].empty?
      @automation_scripts = @automation_scripts.where(:owner_id => params[:search_by_owner])
    end
    if params[:search_by_tag] and not params[:search_by_tag].empty?
      @automation_scripts = @automation_scripts.tagged_with(params[:search_by_tag])
    end

    respond_to do |format|
      format.js { render :json => {:automation_scripts => @automation_scripts} }
    end
  end

  protected

  def resource
    @project = Project.find(params[:project_id])
    @test_suite = TestSuite.find(params[:id])
  end

  def collection
    @project ||= Project.find(params[:project_id])
    @search = @project.test_suites.search(params[:search])
    @test_suites = @search.page(params[:page]).per(15)
  end
end
