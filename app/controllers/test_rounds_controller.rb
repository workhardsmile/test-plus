require 'csv'
class TestRoundsController < InheritedResources::Base
  respond_to :js
  respond_to :csv
  belongs_to :project
  before_filter :authenticate_user!, :only => [:new, :crete]

  def config_notify_email
    @test_round = TestRound.find(params[:test_round_id])
    @notification_emails = @test_round.notification_emails
    respond_to do |format|
      format.html { render :layout => false}
      format.js { render :layout => false}
    end
  end
  def send_notify_email
    @test_round = TestRound.find(params[:test_round_id])
    @notification_emails = params[:notify_emails]

    respond_to do |format|
      unless @notification_emails.empty?
        unless @notification_emails.split(',').any?{|email| not_a_valid_email?(email.strip)}
          TestRoundMailer.notify_mail(@test_round.id,@notification_emails).deliver
        else
          flash[:notice] = "there is invalid email address, please check."
        end
        format.js { render :layout => false}
      else
        flash[:notice] = "please select or enter email address."
        format.js { render :layout => false}
      end
    end
  end
  def rerun_failed
    test_round = TestRound.find(params[:test_round_id])
    # rerun_automation_script_results(test_round, test_round.automation_script_results.where("result != 'pass' and triage_result ='N/A'"))
    rerun_automation_script_results(test_round, test_round.automation_script_results.where("result != 'pass' and error_type_id is null"))
    render :nothing => true
  end
  def rerun
    test_round = TestRound.find(params[:test_round_id])
    rerun_automation_script_results(test_round, test_round.automation_script_results)
    render :nothing => true
  end

  def create
    create! do
      @test_round.counter = 3 if params[:enable_auto_rerun] == "on"
      @test_round.set_default_value
      @test_round.save
      TestRoundDistributor.distribute(@test_round.id)
      project_test_rounds_path(@project)
    end
  end

  def save_to_testlink
    SaveResultToTestlink.save(params[:test_round_id],params[:dev_key],params[:project_name],params[:test_plan_name],params[:build_name],params[:platform_name],params[:email])
    render :nothing => true
  end

  def execute_multiple_site
    ActivenetMultipleSiteDistributor.distribute(params)
    redirect_to project_test_rounds_path(Project.find_by_name('ActiveNet'))
  end

  def show_report
    @project ||= Project.find(params[:project_id])
    @test_round ||= TestRound.find(params[:test_round_id])
    @triage_result_analysis = @test_round.triage_result_analysis    
  end

  protected
  def resource
    @project ||= Project.find(params[:project_id])
    @test_round ||= TestRound.find(params[:id])
    @search = @test_round.automation_script_results.search(params[:search])
    @automation_script_results = @search.order('id desc').page(params[:page]).per(15)
  end

  def collection
    @project ||= Project.find(params[:project_id])
    @search = @project.test_rounds.search(params[:search])
    @test_rounds ||= @search.order('id desc').page(params[:page]).per(15)
  end
  private

  def rerun_automation_script_results(test_round, automation_script_results)
    branch_name = test_round.branch_name
    existing_branch_scripts = ProjectBranchScript.where(:project_id => test_round.project_id, :branch_name => branch_name).map(&:automation_script_name)

    automation_script_results.each do |asr|
      # conditions about rerun
      # the status of automation script is 'completed', otherwise marked it as 'Not Ready'
      # the script is in current branch, otherwise marked it as 'Not in Branch'
      # if there is no slave_assignment, create a new one
      # if there is existing slave assignment, reset it for rerun

      if asr.automation_script.status =='Completed'
        if (branch_name != 'master') and existing_branch_scripts.index(asr.automation_script.name).nil?
          asr.set_to_not_in_branch
        else
          asr.clear
          AutomationScriptResultRunner.rerun(asr.id)
        end
      else
        asr.set_to_not_ready
      end
    end
  end

  def not_a_valid_email?(email)
    (email =~ /\A([\S].?)+@(activenetwork|active)\.com\z/i).nil?
  end

end
