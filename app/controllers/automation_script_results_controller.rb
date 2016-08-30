class AutomationScriptResultsController < InheritedResources::Base
  respond_to :js
  belongs_to :test_round

  def view_triage_result
    @automation_script_result ||= AutomationScriptResult.find(params[:id])
    @test_round ||= @automation_script_result.test_round
    @triage_result ||= @automation_script_result.triage_result

    respond_to do |format|
      format.html { render :layout => false}
      format.js { render :layout => false}
    end
  end

  def add_triage_result
    @automation_script_result ||= AutomationScriptResult.find(params[:id])
    @test_round ||= @automation_script_result.test_round
    @triage_result ||= @automation_script_result.triage_result

    respond_to do |format|
      format.html { render :layout => false}
      format.js { render :layout => false}
    end
  end

  def save_triage_result
    @automation_script_result ||= AutomationScriptResult.find(params[:automation_script_result_id])
    respond_to do |format|
      begin
        @automation_script_result.triage_result = params[:triage_result]
        @automation_script_result.error_type_id = params[:error_type_id]

        result_type = ErrorType.find(params[:error_type_id]).result_type

        case result_type
        when 'pass'
          @automation_script_result.automation_case_results.each do |acr|
            acr.result = 'pass'
            acr.save
          end
          @automation_script_result.result = 'pass'
        when 'failed'
          @automation_script_result.automation_case_results.where(:result => 'not-run').each do |acr|
            acr.result = 'failed'
            acr.save
          end
          @automation_script_result.result = 'failed'
        when 'N/A'
          @automation_script_result.automation_case_results.each do |acr|
            acr.result = 'not-run'
            acr.save
          end
          @automation_script_result.result = 'failed'
        end
        @automation_script_result.save
        @automation_script_result.count_automation_script_and_test_round_result

        if params['override']
          as = @automation_script_result.automation_script
          as.note = @automation_script_result.triage_result
          as.save
        end
        format.js {}
      rescue Exception => e
        @automation_script_result.errors[:triage_result] << e
        format.js {}
      end
    end
  end

  def rerun(automation_script_result_id=params[:id])
    automation_script_result = AutomationScriptResult.find(automation_script_result_id)
    test_round = automation_script_result.test_round
    automation_script_result.clear

    if automation_script_result.is_in_current_branch?
      if automation_script_result.automation_script.status == 'Completed'
        AutomationScriptResultRunner.rerun(automation_script_result_id)
      else
        automation_script_result.set_to_not_ready
      end
    else
      automation_script_result.set_to_not_in_branch
    end
    render :nothing => true
  end

  def stop
    asr = AutomationScriptResult.find(params[:id])
    if not asr.end?
      asr.state = "stopping"
      asr.save
      sa = asr.slave_assignments.last if asr
      SlaveAssignmentsHelper.send_slave_assignment_to_list sa, "stop" if sa
    end

    render :nothing => true
  end

  def show_logs
    @test_round ||= TestRound.find(params[:test_round_id])
    @project ||= @test_round.project
    @automation_script_result ||= AutomationScriptResult.find(params[:automation_script_result_id])
    @slave_assignment ||= @automation_script_result.slave_assignments.last
  end

  protected
  def resource
    @test_round ||= TestRound.find(params[:test_round_id])
    @project = @test_round.project
    @automation_script_result ||= AutomationScriptResult.find(params[:id])
    @search = @automation_script_result.automation_case_results.search(params[:search])
    @automation_case_results = @search.page(params[:page]).per(15)
    @automation_case_results.sort!{|acr1, acr2| acr1.case_id <=> acr2.case_id}
  end

  def collection
    @test_round ||= TestRound.find(params[:test_round_id])
    @search = @test_round.automation_script_results.search(params[:search])
    @automation_script_results ||= @search.order('id desc').page(params[:page]).per(15)
  end
end
