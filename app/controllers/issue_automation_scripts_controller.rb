class IssueAutomationScriptsController < InheritedResources::Base
  respond_to :js
  belongs_to :project
  belongs_to :issue
  def new
    @issue_automation_script = IssueAutomationScript.new
    @issue_automation_script.issue = Issue.new
    unless params[:issue_automation_script].nil?
      @issue_automation_script.set_attributes_from_hash_params(params[:issue_automation_script])
      @issue_automation_script.issue.set_attributes_from_hash_params(params[:issue_automation_script])
    end
    @issue_automation_script.project_id = params[:project_id]
    @message = params[:message]
    respond_to do |format|
      format.html {}
      format.js { render :layout=>false }
    end
  end

  def create
    err_flag = true
    if IssueAutomationScriptsHelper.string_is_empty?(params[:issue_automation_script][:issue_display_id]) || IssueAutomationScriptsHelper.string_is_empty?(params[:issue_automation_script][:automation_script_name])
      redirect_to new_project_issue_automation_script_path(:project_id=>params[:issue_automation_script][:project_id],:issue_automation_script=>params[:issue_automation_script],:message=>"* Both [Issue id] and [Script name] are required!")
    else     
      message = "Create #{params[:issue_automation_script][:issue_display_id]}<->#{params[:issue_automation_script][:automation_script_name]} failed! "
      @issue = IssuesHelper.create_or_update_from_issue_params(params[:issue_automation_script])
      if @issue
        params[:issue_automation_script][:issue_id]=@issue.id
        @issue_automation_script = IssueAutomationScriptsHelper.create_or_update_from_issue_automation_script_params(params[:issue_automation_script])
        if @issue_automation_script
          err_flag = false
          if session[:pre_issue_url].nil?
            redirect_to project_issue_automation_scripts_path(@issue_automation_script.project)
          else
            redirect_to session[:pre_issue_url]
          end
        else
          message += "\n\t#{@issue_automation_script.errors}"
        end
      else
        message += "\n\t#{@issue.errors}"
      end
      if err_flag
        redirect_to new_project_issue_automation_script_path(:project_id=>params[:issue_automation_script][:project_id],:issue_automation_script=>params[:issue_automation_script],:message=>message)
      end
    end
  end

  def update   
    @issue_automation_script = IssueAutomationScript.find(params[:id])
    if IssueAutomationScriptsHelper.string_is_empty?(params[:issue_automation_script][:issue_display_id]) || IssueAutomationScriptsHelper.string_is_empty?(params[:issue_automation_script][:automation_script_name])
      redirect_to edit_project_issue_automation_script_path(@issue_automation_script.project,@issue_automation_script, :message=>"* Both [Issue id] and [Script name] are required!")
    else  
      message = nil   
      begin
        @issue = IssuesHelper.create_or_update_from_issue_params(params[:issue_automation_script])
        params[:issue_automation_script][:issue_id] = @issue.id
        temp = IssueAutomationScript.find_by_issue_id_and_automation_script_name_and_project_id(params[:issue_automation_script][:issue_id],params[:issue_automation_script][:automation_script_name],params[:issue_automation_script][:project_id])
        if temp.nil? || temp.id == @issue_automation_script.id
          @issue_automation_script.set_attributes_from_hash_params(params[:issue_automation_script])
          @issue_automation_script.save!
          redirect_to project_issue_automation_scripts_path(@issue_automation_script.project,:message=>message)
        else
          message = "The record #{params[:issue_automation_script][:issue_display_id]}<->#{params[:issue_automation_script][:automation_script_name]} has existed."
          redirect_to edit_project_issue_automation_script_path(@issue_automation_script.project,@issue_automation_script,:message=>message)
        end
      rescue => e
        message = "Update #{@issue_automation_script.issue_display_id}<->#{@issue_automation_script.automation_script_name} failed! \n\t#{@issue_automation_script.errors}"
        redirect_to edit_project_issue_automation_script_path(@issue_automation_script.project,@issue_automation_script,:message=>message)
      end
    end
  end

  def destroy
    @issue_automation_script = IssueAutomationScript.find(params[:id])
    issue_display_id = @issue_automation_script.issue_display_id
    automation_script_name = @issue_automation_script.automation_script_name
    begin
      @issue_automation_script.issue = nil
      @issue_automation_script.destroy
      redirect_to project_issue_automation_scripts_path(:project_id=>params[:project_id],:message=>"Delete #{issue_display_id}<->#{automation_script_name} successfully!")
    rescue => e
      redirect_to project_issue_automation_scripts_path(:project_id=>params[:project_id],:message=>"Delete #{issue_display_id}<->#{automation_script_name} failed! \n\t#{@issue_automation_script.errors}")
    end
  end

  def get_issues_by_issue_display_id
    like_issues = IssuesHelper.find_issues_like_issue_display_id(params[:issue_display_id],params[:project_id])
    respond_to do |format|
      format.json { render json: like_issues }
    end
  end

  def get_scripts_by_script_name
    like_scripts = AutomationScriptsHelper.find_scripts_like_name(params[:script_name],params[:project_id])
    respond_to do |format|
      format.json { render json: like_scripts }
    end
  end

  def get_cases_by_case_id
    like_cases = AutomationCasesHelper.find_cases_like_case_id(params[:case_id],params[:script_name],params[:project_id])
    respond_to do |format|
      format.json { render json: like_cases }
    end
  end

  protected

  def resource
    @message = params[:message]
    @project ||= Project.find(params[:project_id]) unless params[:project_id].nil?
    @issue_automation_script ||= IssueAutomationScript.find(params[:id])
    @issue = @issue_automation_script.issue || Issue.new
  end

  def collection
    @message = params[:message]
    @project ||= Project.find(params[:project_id])
    @search = @project.issue_automation_scripts.search(params[:search])
    if params[:issue_id]!=nil
      @project ||= Project.new
      @issue ||= Issue.find(params[:issue_id])
      @search = @issue.issue_automation_scripts.search(params[:search])
    else
      @issue ||= Issue.new
    end
    @issue_automation_scripts ||= @search.order('id desc').page(params[:page]).per(15)
  end
end
