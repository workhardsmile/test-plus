class ProjectBranchScriptsController < ApplicationController
  def import
    project_id = Project.find_by_name(params[:project_name]).id
    branch_name = params[:branch_name]
    scripts = params[:scripts].uniq

    existing_branch_scripts = ProjectBranchScript.where(:project_id => project_id, :branch_name => branch_name).map(&:automation_script_name)
    (scripts-existing_branch_scripts).each do |s|
      ProjectBranchScript.create(:project_id => project_id, :branch_name => branch_name, :automation_script_name => s)
    end

    @project_branch_scripts = ProjectBranchScript.where(:project_id => project_id, :branch_name => branch_name)
    render json: @project_branch_scripts
    
  end


end
