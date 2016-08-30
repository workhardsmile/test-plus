class StatusController < ApplicationController
  def new_build
    logger.info "New Build incoming. #{params}"
    ci_value = params[:project].split(/_|-/).map{|n| n.capitalize}.join('')
    env = params[:environment]
    branch_name = params.has_key?(:branch_name) ? params[:branch_name] : "master"
    parameter = params.has_key?(:parameter) ? params[:parameter] : ""
    enable_auto_rerun = params.has_key?(:enable_auto_rerun) ? params[:enable_auto_rerun] : "off"
    @test_round_ids= []
    unless env.empty?
      test_object = "#{ci_value} #{params[:version]}"
      CiMapping.find_all_by_ci_value(ci_value).each do |ci_mapping|
        unless ci_mapping.project.branches.index branch_name
          logger.error "Branch #{parameter} could not be found: #{ci_mapping.inspect}"
          return
        end
        test_environment = ci_mapping.project.test_environments.find_by_name(env)
        if test_environment
          #kill running test rounds
          ServiceTriggerRecord.where(:test_environment =>test_environment.name,:test_suite_id => ci_mapping.test_suite_id, :status => "running").select{|t| TestRoundKiller.kill(t.test_round_id)}
          test_round = TestRound.create_for_new_build(ci_mapping.test_suite, ci_mapping.project, test_environment, User.automator, test_object, ci_mapping.browser, ci_mapping.operation_system, branch_name, parameter, enable_auto_rerun)
          TestRoundDistributor.distribute(test_round.id)
          @test_round_ids << test_round.id
          ServiceTriggerRecord.create(:project_mapping_name => ci_value, :test_round_id => test_round.id, :project_id => test_round.project.id, :status => "running", :test_environment => test_environment.name, :test_suite_id => ci_mapping.test_suite_id ).save
        else
          logger.error "Test Environment #{env} is not assigned to project #{ci_mapping.project.name}"
        end
      end
    end
    render "status/new_build"
  end

  def test_round_status
    @test_round = TestRound.find(params[:id])
    render "status/test_round_status"
  end

  def update
    if request.remote_ip != '127.0.0.1'
      render :text => "Not allowed to call this interface from outside server."
    else
      protocol = params[:protocol]
      what = protocol[:what]
      test_round_id = protocol[:round_id]
      logger.info "#{protocol}"
      test_round = TestRound.find(test_round_id)

      automation_script_result = test_round.find_automation_script_result_by_script_name(protocol[:data]['script_name'])
      #if automation_script_result and not automation_script_result.end?
      if automation_script_result
        case what

        when 'Script'
          if automation_script_result.state == "running" or automation_script_result.state == "scheduling" or (automation_script_result.state == "stopping" and protocol[:data]['state'] and protocol[:data]['state'].downcase == "killed")
            update_automation_script(test_round, protocol[:data])
          end
        when 'Case'
          update_automation_case(test_round, protocol[:data])
        end
      end
      render :nothing => true
    end
  end

  protected
  def update_automation_script(test_round, data)
    #    if test_round.state != "completed"
    state = data['state'].downcase
    automation_script_result = test_round.find_automation_script_result_by_script_name(data['script_name'])
    if ( (state == 'done' || state == 'failed') && data['service'])
      automation_script_result.target_services.delete_all
      TargetService.create_services_for_automation_script_result(data['service'], automation_script_result)
    end
    automation_script_result.update_state!(state)
    test_round.update_state!
    if test_round.end?
      # check if any counter of automation script result is lower than test round's
      # rerun failed scripts if any, otherwise send finish email
      rerunnable_scripts = test_round.auto_rerunable_scripts
      if rerunnable_scripts.size > 0
        rerunnable_scripts.each do |asr|
          asr.clear
          sa = asr.slave_assignments.first
          sa.reset!
          sa.save
          SlaveAssignmentsHelper.send_slave_assignment_to_list sa, :pending
        end
      else
        TestRoundMailer.finish_mail(test_round.id).deliver
      end
    end
  end

  def update_automation_case(test_round, data)
    script_name = data['script_name']
    screen_shot_name = data["screen_shot"]

    automation_script = test_round.find_automation_scirpt_by_script_name(script_name)
    automation_script_result = test_round.find_automation_script_result_by_script_name(script_name)
    automation_case = automation_script.find_case_by_case_id(data['case_id'])
    unless automation_case.nil?
      automation_case_result = automation_script_result.find_case_result_by_case_id(automation_case.id)
      automation_case_result.screen_shot = screen_shot_name unless (screen_shot_name.nil? or screen_shot_name.empty?)
      automation_case_result.server_log = data['server_log'] unless data['server_log'].nil?
      automation_case_result.update!(data)
      automation_case_result.save!
    end
  end
end
