class AutomationScriptsController < InheritedResources::Base
  respond_to :js
  belongs_to :project
  def view_note
    @automation_script ||= AutomationScript.find(params[:automation_script_id])
    @project ||=  @automation_script.project
    respond_to do |format|
      format.html { render :layout => false}
      format.js { render :layout => false}
    end
  end
  def edit_note
    @automation_script ||= AutomationScript.find(params[:automation_script_id])
    @project ||=  @automation_script.project
    respond_to do |format|
      format.html { render :layout => false}
      format.js { render :layout => false}
    end
  end

  def save_note
    @automation_script ||= AutomationScript.find(params[:automation_script_id])
    @automation_script.note=params[:note]    
    respond_to do |format|
      begin
        @automation_script.save
        format.js {}
      rescue Exception => e
        @automation_script.errors[:note] << e
        format.js {}
      end
    end
  end
  protected
  def resource
    @project ||= Project.find(params[:project_id])
    @automation_script ||= AutomationScript.find(params[:id])
  end

  def collection
    @project ||= Project.find(params[:project_id])
    @search = @project.automation_scripts.search(params[:search])
    @automation_scripts ||= @search.page(params[:page]).per(15)
  end
end
