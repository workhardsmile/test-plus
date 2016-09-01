class IssuesController < InheritedResources::Base
  respond_to :js
  belongs_to :project
  
  def index
    redirect_to project_issue_automation_scripts_path(@project)
  end
end
