class AutomationProgressesController < ApplicationController
  layout 'automation_progress'
  def index
  end

  def dump_all_monitor_projects
    date = Date.today
    result = Hash.new
    Project.where(:monitor_flag => true).each do |project|
      begin
        progress = AutomationProgress.find_by_project_id_and_record_date(project.id,date)
        progress = project.automation_progresses.build(:record_date => date) if progress.nil?
        progress.save_regression_coverage
        result[project.name]="done"
      rescue Exception => e
        result[project.name]="failed"
      end
    end
    render json: result
  end
  def create
    @project=Project.find(params[:project_id])
    date = Date.today
    @auto_progress = AutomationProgress.find_by_project_id_and_record_date(@project.id,date)
    @auto_progress = @project.automation_progresses.build(:record_date => date) if @auto_progress.nil?
    @auto_progress.save_regression_coverage
    render json: @auto_progress
  end
  def project_progress
    @project = Project.find(params[:project_id])
    @progress = @project.recent_automation_progress
    respond_to do |format|
      format.js {}
    end
  end
end
